import pickle
from surprise import SVD, Dataset, Reader
from surprise.model_selection import train_test_split

# Assuming 'interactions_df' is already prepared as previously described
reader = Reader(rating_scale=(0, 1))
data = Dataset.load_from_df(interactions_df[['User_ID', 'News_ID', 'Clicked']], reader)
trainset = data.build_full_trainset()

# Train the SVD model
model = SVD()
model.fit(trainset)

# Save the model to a file
with open('recommendation_model.pkl', 'wb') as file:
    pickle.dump(model, file)