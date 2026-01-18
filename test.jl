
########## test the model ###########
include("src/model.jl")

Random.seed!(45)
model = monetary_model{Float64}()

populate!(model,        # model
            50_000.0,  # total deposits of households
            200_000.0,  # total bank capital
            200_000.0, # total real estate
            200_000.0, # firm total deposits
            400_000.0,  # firm capital goods
            300_000.0, # government fixed assets
            1000,      # number of households
            5,         # number of banks
            100)       # number of firms

populate_labour_market!(model)

df = simulate(model, 36, true)

model.firms[2].p
price_level(model)

cutoff = 5

plot(df.inventory[cutoff:end], title = "Total Inventory")
plot(df.consumption[cutoff:end], title = "Monthly Consumption")
plot(df.production[cutoff:end], title = "Monthly Production")
plot(df.firm_capital[cutoff:end], title = "Total Firm Capital")
plot(df.hh_capital[cutoff:end], title = "Total Household Capital")
plot(df.hh_capital[cutoff:end] + df.firm_capital[cutoff:end], title = "Total Private Capital")
plot(df.p[cutoff:end], title = "Price Level")
plot(df.reserves[cutoff:end])

maximum(model.firms[i].p for i in 1:length(model.firms))

deposits(model)



2+2

v = [1,2,3,4]

