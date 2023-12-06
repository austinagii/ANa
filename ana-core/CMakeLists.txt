# cmake_minimum_required(VERSION 3.5 FATAL_ERROR)
# project(senti)

# # Include the FetchContent module for downloading dependencies
# include(FetchContent)

# # Find the Python library. Ensure that it's installed on your system
# find_package(Python COMPONENTS Development Interpreter REQUIRED)
# # Find the Torch library. Ensure that it's installed on your system
# find_package(Torch REQUIRED)

# # Fetch the nlohmann/json library from the given URL
# FetchContent_Declare(
#   json 
#   URL https://github.com/nlohmann/json/releases/download/v3.11.2/json.tar.xz
# )
# FetchContent_MakeAvailable(json)

# # Fetch pybind11 from the specified Git repository
# FetchContent_Declare(
#   pybind11 
#   GIT_REPOSITORY https://github.com/pybind/pybind11.git 
#   GIT_TAG v2.6.1
# )
# FetchContent_MakeAvailable(pybind11)

# # Set C++17 as the standard
# set(CMAKE_CXX_STANDARD 17)
# set(CMAKE_CXX_STANDARD_REQUIRED ON)
# add_compile_options(-Wall)
# set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# # Create a Python module using pybind11 that includes your source files
# pybind11_add_module(senti MODULE 
#   src/sentc/senti.cpp 
#   src/sentc/preprocessing.cpp
# )

# # Link the Python module with the required libraries
# target_link_libraries(senti PRIVATE "${Python_LIBRARIES}" "${TORCH_LIBRARIES}" pybind11::pybind11 nlohmann_json::nlohmann_json)
 

cmake_minimum_required(VERSION 3.5 FATAL_ERROR)
project(senti)

# Include the FetchContent module for downloading dependencies
include(FetchContent)

# Find the Python library. Ensure that it's installed on your system
find_package(Python COMPONENTS Development Interpreter REQUIRED)

# Find the Torch library. Ensure that it's installed on your system
find_package(Torch REQUIRED)

# Fetch the nlohmann/json library from the given URL
FetchContent_Declare(
  json 
  URL https://github.com/nlohmann/json/releases/download/v3.11.2/json.tar.xz
)
FetchContent_MakeAvailable(json)

# Fetch pybind11 from the specified Git repository
FetchContent_Declare(
  pybind11 
  GIT_REPOSITORY https://github.com/pybind/pybind11.git 
  GIT_TAG v2.6.1
)
FetchContent_MakeAvailable(pybind11)

# Set C++17 as the standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
add_compile_options(-Wall)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# Create a Python module using pybind11 that includes your source files
pybind11_add_module(senti MODULE 
  src/sentc/senti.cpp 
  src/sentc/preprocessing.cpp
)

# Link the Python module with the required libraries
target_link_libraries(senti PRIVATE "${Python_LIBRARIES}" pybind11::pybind11 "${TORCH_LIBRARIES}" nlohmann_json::nlohmann_json)
