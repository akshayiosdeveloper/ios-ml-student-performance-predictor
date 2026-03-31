import pandas as pd
from sklearn.model_selection import train_test_split
# This splits the dataset into: Training data and Testing data
from sklearn.ensemble import RandomForestClassifier
# This imports the algorithm we are using. 
# Random Forest = Many decision trees → voting → final result
from sklearn.metrics import accuracy_score
# This helps us measure how good our model is.
import pickle
# This library saves the trained model so we can use it later in the API.

# create dataset
data = {
    "hours_studied": [2,3,5,6,7,8,1,4,6,7,3,9],
    "sleep_hours": [5,6,6,7,7,8,4,5,7,6,5,8],
    "practice_tests": [0,1,2,2,3,4,0,1,2,3,1,4],
    "pass_exam": [0,0,1,1,1,1,0,0,1,1,0,1]
}
# convert to the dataframe
df = pd.DataFrame(data)
# print(df.head())

# separate feature set and data set
X = df.drop("pass_exam",axis=1)
# print(X)
y = df["pass_exam"]
print("----\n")
# print(y)

# split training and testing data
X_train ,X_test , y_train,y_test = train_test_split(X,y,test_size=0.2,random_state=42)
print(len(X_train))
print(len(X_test))

# create model

model = RandomForestClassifier(n_estimators=100, max_depth=5,random_state=42)

# train model 
model.fit(X_train,y_train)

# print(X_train.index)
# print("-----")
# print("\n y_train:")
# print(y_train)

print("\n Combined Training Data ❤️  ❤️ ❤️:")
train_data = X_train.copy()
train_data["pass_exam"] = y_train
print(train_data)

# Step 9 — Test the Model
predictions = model.predict(X_test)
print("Actual:(X_test)----->", y_test.values)
print("Predicted:(y_test.values)----->:", predictions)

# Step 10 — Check Accuracy
accuracy_score = accuracy_score(y_test,predictions)
print(" ❤️ Model Accuracy:------>  👀👀👀👀  :", accuracy_score)

# Step 11 — Save the Model
pickle.dump(model,open("model.pkl","wb"))
print(" ✅✅✅✅ Model saved successfully! ✅✅✅✅✅✅✅✅✅ ")