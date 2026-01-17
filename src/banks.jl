  


function excess_reserves(bank::Bank{Float64}, model::monetary_model)
    return bank.reserves - (bank.deposits * model.min_reserve_ratio)
end

function deposits(model::monetary_model)
    total_deposits = 0.0

    for bank in model.banks
        total_deposits += bank.deposits
    end

    return total_deposits
end