mutable struct CentralBank{V <: AbstractFloat}

    # balance sheet - assets
    bonds::V                    # government bonds
    reserve_assets::V           # foreign exchange reserves, gold, etc.

    # balance sheet - liabilities
    reserves::V     # central bank money issued to banks or government
end