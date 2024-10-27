import faiss
import numpy as np
#import lightgbm as lgb
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split
from sklearn.datasets import make_classification
from sklearn.preprocessing import OneHotEncoder
from sklearn.metrics import accuracy_score
import tensorflow as tf
from tensorflow.keras.layers import Input, Embedding, Dense, Concatenate, Flatten, Attention
from tensorflow.keras.models import Model
from .nets.postside.postside import reduce_dimensionality, post_embeddings

def main():
    print(create_post_embedding('/Users/macbookair/Documents/Project/fItneSS_us/backend/recommendation/datasets/celebA_50k/000001.jpg', 'title', 'This is an example sentence.'))
    #recall()
    #rough_ranking()
    #fine_ranking()

def create_post_embedding(img_path, title, description):
    return(post_embeddings(img_path, title, description))

def search_similar_posts(query_embedding, index, post_ids, k=100):
    D, I = index.search(query_embedding.reshape(1, -1), k)  # D: Distances, I: Indices
    return post_ids[I[0]], D[0]

def recall(embeddings_path, user_embeddings):
    embeddings, post_ids = read_embeddings(embeddings_path)

    # Normalize the embeddings for cosine similarity
    faiss.normalize_L2(embeddings)

    # Create the index
    index = faiss.IndexFlatL2(64)  # Use IndexFlatIP for cosine similarity (inner product)
    index.add(embeddings)

    similar_post_ids, distances = search_similar_posts(user_embeddings, index, post_ids, 100)
    print("Similar Post IDs:", similar_post_ids)
    print("Distances:", distances)
    return similar_post_ids

def read_embeddings(file_path, dim=64):
    # Adjust dtype based on how data is stored and the precise structure
    dt = np.dtype([('embedding', np.float32, (dim,)), ('post_id', np.int32)])
    data = np.fromfile(file_path, dtype=dt)
    embeddings = np.array([d['embedding'] for d in data])
    post_ids = np.array([d['post_id'] for d in data])
    return embeddings, post_ids

if __name__ == '__main__':
    main()