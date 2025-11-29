import pandas as pd
import pickle


linkers = pd.read_csv('data/total_dataset.csv')

with open('data/embeddings_large/unique_insideout_tmds_pseudomonas_processed/last_hidden_state_esm2_t48_15B_UR50D.pkl', 'rb') as f:
    data = pickle.load(f)