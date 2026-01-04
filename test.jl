########## test the model ###########
include("src/model.jl")


Random.seed!(45)
model = monetary_model{Float64}()

populate!(model,        # model
            200_000.0,  # total deposits of households
            100_000.0,  # total bank capital
            200_000.0, # total real estate
            100_000.0, # firm total deposits
            400_000.0,  # firm capital goods
            800_000.0, # government fixed assets
            1000,      # number of households
            5,         # number of banks
            100)       # number of firms

populate_labour_market!(model)



df = simulate(model, 21, false)

plot(df.inventory, title = "Total Inventory")
plot(df.consumption, title = "Daily Consumption")
plot(df.production, title = "Daily Production")
plot(df.firm_capital, title = "Total Firm Capital")
plot(df.hh_capital, title = "Total Household Capital")
plot(df.p, title = "Price Level")