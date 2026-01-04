############ initiate model ###########

function populate!(model::monetary_model, 
                    total_deposit::Float64, 
                    total_bank_capital::Float64,
                    total_real_estate::Float64,
                    firm_total_deposits::Float64,
                    firm_capital_goods::Float64,
                    gov_fixed_assets::Float64, 
                    n_hh::Int64, 
                    n_banks::Int64,
                    n_firms::Int64)

    model.n_hh = n_hh
    model.n_banks = n_banks
    model.n_firms = n_firms

    model.central_bank = CentralBank{Float64}(0.0, 
                                              total_deposit + firm_total_deposits, 
                                              total_deposit + firm_total_deposits)
    model.government = Government{Float64}(gov_fixed_assets, 0.0, 0.0)

    ###### distribute bank capital and deposits among banks #####
    bank_shares = rand(Pareto(1.5, 1), n_banks)
    bank_shares = bank_shares ./ sum(bank_shares)

    bank_capital_dsitribution = bank_shares .* total_bank_capital

    for i in 1:n_banks
        push!(model.banks, Bank{Float64}(i, 0.0, 0.0, 0.0, bank_capital_dsitribution[i], 0.0))
    end

    ###### distribute deposit among households #####
    deposit_dsitribution = rand(Pareto(1.1, 1), n_hh)
    deposit_dsitribution .= deposit_dsitribution ./ sum(deposit_dsitribution) .* total_deposit

    ###### assign each household and its deposit to a bank #####
    for i in 1:n_hh
        bank_id = sample(1:n_banks, Weights(bank_shares)) # chance of choosing a bank proportional to its size
        push!(model.households, Household{Float64}(i, bank_id, 0, zeros(Float64, model.n_firms), deposit_dsitribution[i], 0.0, 0.0, 0.0, 1.0))

        model.banks[bank_id].deposits += model.households[i].deposits
        model.banks[bank_id].reserves += model.households[i].deposits
    end

    ###### randomly assign normalized shares to households #####
    shares_matrix = rand(Pareto(1.1, 1), model.n_hh, model.n_firms)
    shares_matrix ./= sum(shares_matrix, dims=1)

    for i in 1:model.n_hh
        for j in 1:model.n_firms
            model.households[i].shares[j] = shares_matrix[i, j]
        end
    end

    ###### distribute real estate among first households #####
    n_house = total_real_estate / 1_000
    owners = shuffle(vcat([1 for i in 1:Int(n_house)], [0 for i in 1:(n_hh - Int(n_house))]))

    for i in 1:n_hh
        model.households[i].real_estate = 1_000 * owners[i]
    end

    ##### distribute firm deposits among firms #####
    firm_deposit_distribution = rand(Pareto(1.3, 1), n_firms)
    firm_deposit_distribution .= firm_deposit_distribution ./ sum(firm_deposit_distribution) .* firm_total_deposits
    for i in 1:n_firms
        bank_id = sample(1:n_banks, Weights(bank_shares)) # chance of choosing a bank proportional to its size
        push!(model.firms, Firm{Float64}(i, bank_id, Float64[], firm_deposit_distribution[i], firm_capital_goods / n_firms, 0.0, 0.0, 0.0, 0.0))

        model.banks[bank_id].deposits += model.firms[i].deposits
        model.banks[bank_id].reserves += model.firms[i].deposits
    end
    
    ##### Check accounts #####
    account_check(model)
    @assert all(capital(model.households, model) .>= 0.0) "Some households have negative capital after population!"
    @assert all(capital(model.banks, model) .>= 0.0) "Some banks have negative capital after population!"
end

function populate_labour_market!(model::monetary_model)

    # assign each household to a firm as an employer. proportional to firm size (capital)
    firm_sizes = zeros(Float64, model.n_firms)
    for firm in model.firms
        firm_sizes[firm.id] = firm.fixed_assets
    end
    
    firm_size_weights = firm_sizes ./ sum(firm_sizes)
    
    for household in model.households
        employer_id = sample(1:model.n_firms, Weights(firm_size_weights))
        household.employer_id = employer_id
        push!(model.firms[employer_id].employees_ids, household.id)
    end

end    

########### simulation ############

function simulate(model, 
                  T::Int64; 
                  wage_step::Int64 = 30,
                  produce_step::Int64 = 7,
                  consume_step::Int64 = 3,
                  dividend_step::Int64 = 365,
                  verbose::Bool = true)

    aggregate_stats = DataFrame(money = zeros(Float64, T), 
                                 hh_capital = zeros(Float64, T), 
                                 firm_capital = zeros(Float64, T),
                                 reserves = zeros(Float64, T), 
                                 inventory = zeros(Float64, T), 
                                 production = zeros(Float64, T),
                                 consumption = zeros(Float64, T),
                                 p = zeros(Float64, T))

    ###### initial conditions #####
    p = 1.0 # price level
    [model.firms[i].p = p for i in 1:model.n_firms]

    ##### simulation #####
    for t in 1:T

        ###### payout of wages #####
        for firm in model.firms 

        firm.id % wage_step != t % wage_step ? continue : nothing  # firms pay wages once in a week

            firm.labour_cost = 0.0
            for employee in firm.employees_ids
                wage = 1.5
                model.households[employee].deposits += wage
                model.households[employee].w = wage
                firm.deposits -= wage
                firm.labour_cost += wage

                model.banks[model.households[employee].bank_id].deposits += wage
                model.banks[firm.bank_id].deposits -= wage

                model.banks[model.households[employee].bank_id].reserves += wage
                model.banks[firm.bank_id].reserves -= wage
            end
        end    

        ###### produce and set price ######
        GDP = 0.0
        for firm in model.firms

            firm.id % produce_step != t % produce_step ? continue : nothing  # firms produce once in a week

            prod = production(firm, model)

            GDP += prod
            firm.inventory += prod

            # price setting
            produce_to_wage_freq = wage_step / produce_step # to adjust for different frequencies of wage and production payment
            firm.p *= ((firm.labour_cost * produce_to_wage_freq) / (firm_capacity(firm, model) * firm.p)) * (price_level(model) / firm.p)
        end

        ###### consume #####
        total_consumption = 0.0
        for household in model.households

            # consume once in a few days
            household.id % consume_step != t % consume_step ? continue : nothing

            consumption_amount = consumption(household, model)
            consumption_amount == 0.0 ? continue : nothing

            # search and match with a firm
            no_inventory_firms = findall([(model.firms[i].inventory * model.firms[i].p) < consumption_amount for i in 1:model.n_firms])  # firms unable to satisfy consumption

            if length(no_inventory_firms) == model.n_firms
                #verbose ? println("No firm at time $t has enough inventory for household $(household.id)'s consumption.") : nothing
                continue
            end
            matching_probs = match_probability(model)                       # get matching probabilities
            #println(matching_probs)
            matching_probs[no_inventory_firms] .= 0.0                       # set probabilities of unable firms to zero
            if any(isnan.(matching_probs))
                error("NaN encountered in matching probabilities at time $t for household $(household.id). | Matching probs: $matching_probs")
            end
            matching_probs .= matching_probs ./ sum(matching_probs)         # re-normalize
            
            seller_id = sample(1:model.n_firms, Weights(matching_probs))    # sample

            # transaction operations
            household.deposits -= consumption_amount 
            total_consumption += consumption_amount

            model.banks[household.bank_id].deposits -= consumption_amount
            model.banks[household.bank_id].reserves -= consumption_amount

            model.firms[seller_id].deposits += consumption_amount
            model.firms[seller_id].inventory -= (consumption_amount / model.firms[seller_id].p)

            model.banks[model.firms[seller_id].bank_id].deposits += consumption_amount
            model.banks[model.firms[seller_id].bank_id].reserves += consumption_amount
        end    

        ###### dividend payout #####
        for firm in model.firms 
            # pay once in a year
            firm.id % dividend_step != t % dividend_step ? continue : nothing

            excess_capital = firm.deposits - (firm.fixed_assets * 0.4)
            excess_capital <= 0.0 ? continue : nothing
            #println("Firm $(firm.id) pays dividend of $excess_capital at time $t.")

            for household in model.households
                dividend = excess_capital * household.shares[firm.id]
                household.deposits += dividend
                firm.deposits -= dividend

                model.banks[household.bank_id].deposits += dividend
                model.banks[firm.bank_id].deposits -= dividend

                model.banks[household.bank_id].reserves += dividend
                model.banks[firm.bank_id].reserves -= dividend
            end
        end    

        model.p = price_level(model)

        ###### record aggregate stats at time t #####
        aggregate_stats.money[t] = money_supply(model, :M1)
        aggregate_stats.hh_capital[t] = sum(capital(model.households, model))
        aggregate_stats.firm_capital[t] = sum(capital(model.firms, model))
        aggregate_stats.reserves[t] = money_supply(model, :MB)
        aggregate_stats.inventory[t] = sum([model.firms[i].inventory for i in 1:model.n_firms])
        aggregate_stats.production[t] = GDP
        aggregate_stats.consumption[t] = total_consumption
        aggregate_stats.p[t] = price_level(model)

        account_check(model)

        # progress bar
        if verbose
            progress = round(t / T * 100)
            print("\r[")
            for i in 1:progress
                print("=")
            end
            for i in (progress + 1):100
                print(" ")
            end
            print("] $progress %")
        end
    end    

    

    return aggregate_stats
end    