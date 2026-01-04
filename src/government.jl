mutable struct Government{V <: AbstractFloat}

    # balance sheet - assets
    fixed_assets::V   # e.g. infrastructure
    reserves::V     # reserves at the central bank account

    # balance sheet - liabilities
    bonds::V        # government debt
end

function sell_bond!(government::Government{Float64}, bank::Bank{Float64}, amount::Float64)

    government.bonds += amount
    government.reserves += amount

    bank.bonds += amount
    bank.reserves -= amount
end 