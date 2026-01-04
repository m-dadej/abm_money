
function mortgage_scenario!(model::monetary_model,
                            n_mortgages::Int64)

    non_owners = findall([model.households[i].real_estate == 0 for i in 1:model.n_hh])
    buyers = shuffle(non_owners)[1:n_mortgages]
    sellers = findall([i ∉ non_owners for i in 1:model.n_hh]) # possible sellers
    sellers = shuffle(sellers)[1:n_mortgages] # sample from possible sellers

    for pair in 1:length(sellers)

        take_loan!(model.households[buyers[pair]], 
                   model.households[sellers[pair]].real_estate, 
                   model)
        transaction!(model.households[sellers[pair]], 
                     model.households[buyers[pair]],
                     model.households[sellers[pair]].real_estate,
                     :real_estate)
    end    

    account_check(model)
end

function issue_bonds_scenario!(model::monetary_model,
                                amount::Float64,
                                notional::Float64)

    n_bonds = amount / notional

    capable_banks = findall([excess_reserves(model.banks[i], model) >= notional for i in 1:model.n_banks])
    selected_banks = shuffle(capable_banks)[1:Int(min(length(capable_banks), n_bonds))]
    
    for bank_id in selected_banks
        sell_bond!(model.government, model.banks[bank_id], notional)
    end
end

function helicopter_money_scenario!(model::monetary_model,
                                    amount_per_household::Float64)

    amonut = amount_per_household * model.n_hh                                
    
    # finance from all banks without check if they have enough reserves
    for bank_id in 1:model.n_banks
        sell_bond!(model.government, model.banks[bank_id], amonut / model.n_banks)
    end

    for hh in model.households
        hh.deposits += amount_per_household
        model.banks[hh.bank_id].deposits += amount_per_household
        model.banks[hh.bank_id].reserves += amount_per_household
        model.government.reserves -= amount_per_household
    end
    
    account_check(model)
end