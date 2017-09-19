# Source: https://www.bignerdranch.com/blog/machine-learning-in-ios-using-core-ml/
import coremltools
from sklearn import datasets, linear_model
import pandas as pd
from sklearn.externals import joblib

# Load data
boston = datasets.load_boston()
boston_df = pd.DataFrame(boston.data)
boston_df.columns = boston.feature_names

# Define model
X = boston_df.drop(boston_df.columns[[1,2,3,4,6,7,8,9,10,11,12]], axis=1)
Y = boston.target

lm = linear_model.LinearRegression()
lm.fit(X, Y)

# coefficients
lm.intercept_
lm.coef_

# Convert model to Core ML 
coreml_model = coremltools.converters.sklearn.convert(lm, input_features=["crime", "rooms"], output_feature_names="price")

# Save Core ML Model
coreml_model.save("BostonPricer.mlmodel")