mutable struct Bank{V <: AbstractFloat}
    const id::Int64

    # balance sheet - assets
    reserves::V        # central bank money
    bonds::V         # government bonds
    loans::V        # bank loans
    fixed_assets::V  # e.g. buildings, computers, etc. (mostly as a initial capital)

    # balance sheet - liabilities
    deposits::V     # bank deposits
end    


function excess_reserves(bank::Bank{Float64}, model::monetary_model)
    return bank.reserves - (bank.deposits * model.min_reserve_ratio)
end