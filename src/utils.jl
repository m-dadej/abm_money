
# function to add element and remove last one in vector
function update!(v, new_element)
    push!(v, new_element)
    popfirst!(v)
end
