mutable struct Firm{V <: AbstractFloat}

    const id::Int64
    bank_id::Int64  # bank where the firm has an account
    employees_ids::Vector{Int64}  # list of household ids employed by the firm
    
    # balance sheet - assets
    deposits::V      # bank deposits
    fixed_assets::V  # machinery, equipment, etc.
    inventory::V     # goods in stock (units of output)

    # balance sheet - liabilities
    loans::V        # bank loans

    # memory
    labour_cost::V  # last period total labour cost
    p::V             # price level of the firm's product
end

mutable struct Household{V <: AbstractFloat}
    
    const id::Int64
    bank_id::Int64  # bank where the household has an account
    employer_id::Int64  # firm where the household is employed
    
    # balance sheet - assets
    shares::Vector{Float64} # shares owned in firms i (position is firm id)
    deposits::V     # bank deposits
    bonds::V        # government bonds
    real_estate::V  # housing, land, etc.

    # balance sheet - liabilities
    loans::V        # bank loans

    # memory
    w::V  # last period wage
end

mutable struct CentralBank{V <: AbstractFloat}

    # balance sheet - assets
    bonds::V                    # government bonds
    reserve_assets::V           # foreign exchange reserves, gold, etc.

    # balance sheet - liabilities
    reserves::V     # central bank money issued to banks or government
end

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

mutable struct Government{V <: AbstractFloat}

    # balance sheet - assets
    fixed_assets::V   # e.g. infrastructure
    reserves::V     # reserves at the central bank account

    # balance sheet - liabilities
    bonds::V        # government debt
end