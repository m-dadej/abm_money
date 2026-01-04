  


function excess_reserves(bank::Bank{Float64}, model::monetary_model)
    return bank.reserves - (bank.deposits * model.min_reserve_ratio)
end