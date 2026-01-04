

function sell_bond!(government::Government{Float64}, bank::Bank{Float64}, amount::Float64)

    government.bonds += amount
    government.reserves += amount

    bank.bonds += amount
    bank.reserves -= amount
end 