
function price_update!(firm::Firm{Float64}, model::monetary_model)
    
    π_c = (firm.labour_cost / (firm_capacity(firm, model) * firm.p)) # cost push inflation
    
    if (firm.Q_o <= firm.Q_d) & (firm.p < price_level(model)) # high demand & low price case
        π_d = firm.Q_d / firm.Q_o
    elseif (firm.Q_o > firm.Q_d) & (firm.p >= price_level(model)) # low demand & high price case
        π_d = firm.Q_d / firm.Q_o
    else
        π_d = 1.0
    end

    firm.p *= π_c * π_d
end    

function firm_capacity(firm::Firm{Float64}, model::monetary_model)

    #@assert 1 - model.α - model.β < 0 "Returns to scale must be decreasing (1 - α - β < 0)"

    infrastructure_rate = model.government.fixed_assets / model.n_firms
    n_employees = length(firm.employees_ids)

    prod = model.tfr * n_employees^(model.β) * firm.fixed_assets^(model.α) * infrastructure_rate^(1 - model.α - model.β)

    return prod
end    

function firm_capacity(model::monetary_model)

    prod = zeros(Float64, length(model.firms))
    
    for firm in model.firms
        prod[firm.id] = firm_capacity(firm, model)
    end

    return sum(prod)
end

function match_probability(firm::Firm{Float64}, model::monetary_model)

    rel_size_prob = firm_capacity(firm, model) / firm_capacity(model)

    # higher price lower probability
    price_prob = (exp(-2.0 * firm.p)) / sum([exp(-2.0 * model.firms[i].p) for i in 1:model.n_firms])

    return (rel_size_prob + price_prob) / 2.0
end

match_probability(model::monetary_model) = [match_probability(model.firms[i], model) for i in 1:model.n_firms]

function production(firm::Firm{Float64}, model::monetary_model)

    capacity = firm_capacity(firm, model)

    if (firm.Q_o <= firm.Q_d) & (firm.p >= price_level(model))
        γ_d = firm.Q_d / firm.Q_o - 1.0
    elseif (firm.Q_o > firm.Q_d) & (firm.p < price_level(model))
        γ_d = firm.Q_d / firm.Q_o - 1.0
    else
        γ_d = 0.0
    end

    actual_production = min(capacity, firm.Q_o * (1 + γ_d))
    #actual_production = capacity * (1 - (firm.inventory / inv_target))^2
    #actual_production = firm.inventory < inv_target ? capacity : 0.0

    return max(actual_production, 0.0)
end

function capital(agent::Union{Bank, Household, Firm}, model::monetary_model)
    if agent isa Bank
        return agent.reserves + agent.bonds + agent.loans + agent.fixed_assets - agent.deposits
    elseif agent isa Household
        return agent.deposits + agent.bonds + agent.real_estate - agent.loans
    elseif agent isa Firm
        return agent.deposits + agent.fixed_assets + (agent.inventory) - agent.loans # assuming inventory valued at price level 1.0
    end
end

function capital(agents::Vector{T}, model::monetary_model) where T<:Union{Bank, Household, Firm}
    
    capitals = zeros(Float64, length(agents))
    
    for agent in agents
        capitals[agent.id] = capital(agent, model)
    end    

    return capitals
end