using Random
using LinearAlgebra
using Distributions
using StatsBase
using DataFrames
using Plots

include("agents.jl")

Base.@kwdef mutable struct monetary_model{V <: AbstractFloat}
    
    # memory
    p::V = 1.0 # overall price level

    # model parameters
    min_reserve_ratio::V = 0.05
    tfr::V = 2 # total factor productivity
    α::V = 0.35 # capital elasticity
    β::V = 0.7 # labor elasticity
    n_hh::Int64 = 0 # number of households
    n_banks::Int64 = 0 # number of banks
    n_firms::Int64 = 0 # number of firms
    central_bank::CentralBank{V} = CentralBank{V}(0.0, 0.0, 0.0)
    government::Government{V} = Government{V}(0.0, 0.0, 0.0)

    banks::Vector{Bank{V}} = Bank[]
    households::Vector{Household{V}} = Household[]
    firms::Vector{Firm{V}} = Firm[]
end

include("central_bank.jl")
include("government.jl")
include("banks.jl")
include("households.jl")
include("firms.jl")
include("scenarios.jl")
include("simulate.jl")





function money_supply(model::monetary_model, type::Symbol)
    total_deposits = 0.0

    if type == :MB
        return model.central_bank.reserves
    elseif type == :M1
        for bank in model.banks
            total_deposits += bank.deposits
        end
        return total_deposits
    else
        error("Unknown money supply type: $type")
    end
end

price_level(model::monetary_model) = mean([model.firms[i].p for i in 1:model.n_firms])

function account_check(model::monetary_model)

    for bank in model.banks
        @assert bank.deposits >= -0.0001 "Bank $(bank.id) has negative deposits!"
        @assert bank.reserves >= -0.0001 "Bank $(bank.id) has negative reserves!"
        @assert bank.loans >= -0.0001 "Bank $(bank.id) has negative loans!"
        @assert bank.bonds >= -0.0001 "Bank $(bank.id) has negative bonds!"
        @assert excess_reserves(bank, model) >= -0.0001 "Bank $(bank.id) has negative excess reserves!"
        @assert capital(bank, model) >= -0.0001 "Bank $(bank.id) has negative capital!"
    end    

    for household in model.households
        @assert household.deposits >= -0.0001 "Household $(household.id) has negative deposits!"
        @assert household.real_estate >= -0.0001 "Household $(household.id) has negative real estate!"
        @assert household.loans >= -0.0001 "Household $(household.id) has negative loans!"
        @assert household.bonds >= -0.0001 "Household $(household.id) has negative bonds!"
    end

    for firm in model.firms
        @assert firm.deposits >= -0.0001 "Firm $(firm.id) has negative deposits!"
        @assert firm.fixed_assets >= -0.0001 "Firm $(firm.id) has negative fixed assets!"
        @assert firm.loans >= -0.0001 "Firm $(firm.id) has negative loans!"
        @assert firm.inventory >= -0.0001 "Firm $(firm.id) has negative inventory!"
        @assert capital(firm, model) >= -0.0001 "Firm $(firm.id) has negative capital!"
    end

    @assert model.government.bonds >= -0.0001 "Government has negative bonds!"
    @assert model.government.reserves >= -0.0001 "Government has negative reserves!"

    @assert model.central_bank.bonds >= -0.0001 "Central Bank has negative bonds!"
    @assert model.central_bank.reserve_assets >= -0.0001 "Central Bank has negative reserve assets!"
    @assert model.central_bank.reserves >= -0.0001 "Central Bank has negative reserves!"

end