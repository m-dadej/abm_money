

function consumption(household::Household{Float64}, model::monetary_model)

    consumption_amount = min(household.w * 0.1 + household.deposits * 0.01, household.deposits)

    return consumption_amount
end

function take_loan!(household::Household{Float64}, loan_amount::Float64, model::monetary_model)

    bank = model.banks[household.bank_id]

    # increase household deposits and loans
    household.deposits += loan_amount
    household.loans += loan_amount

    # increase bank loans and deposits
    bank.loans += loan_amount
    bank.deposits += loan_amount
    # bank creates money (deposit) by issuing the loan
end

function transaction!(from::Household{Float64}, to::Household{Float64}, amount::Float64, what::Symbol)

    if what == :real_estate
        # transfer real estate 'from' 'to'
        from.real_estate -= amount
        to.real_estate += amount

        # pay for the real_estate
        from.deposits += amount
        to.deposits -= amount
    elseif what == :deposit
        # transfer deposits from 'from' to 'to'
        from.deposits -= amount
        to.deposits += amount
    end

    # transfer deposits and reserves from the banks
    model.banks[from.bank_id].deposits += amount
    model.banks[to.bank_id].deposits -= amount
    model.banks[from.bank_id].reserves += amount
    model.banks[to.bank_id].reserves -= amount
    
end

function aggregate_bs(agents::Vector{T}, model::monetary_model) where T<:Union{Bank,Household}

    total_reserves = 0.0
    total_bonds = 0.0
    total_loans = 0.0
    total_deposits = 0.0
    total_real_estate = 0.0
    total_fixed_assets = 0.0

    for agent in agents
        if agent isa Bank
            total_reserves += agent.reserves
            total_bonds += agent.bonds
            total_loans += agent.loans
            total_fixed_assets += agent.fixed_assets
            total_deposits += agent.deposits
        elseif agent isa Household
            total_real_estate += agent.real_estate
            total_deposits += agent.deposits
            total_bonds += agent.bonds
            total_loans += agent.loans
        end
    end

    total_capital = sum(capital(agents, model))

    
    if agents[1] isa Bank
        println("Aggregate Balance Sheet of banks:")
        println("Total Reserves: $total_reserves")
        println("Total Fixed Assets: $total_fixed_assets")
    else
        println("Aggregate Balance Sheet of households:")
        println("Total Real Estate: $total_real_estate")
    end
    println("Total Bonds: $total_bonds")
    println("Total Loans: $total_loans")
    println("Total Deposits: $total_deposits")
    println("Total Capital: $total_capital")
end