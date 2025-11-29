"""
Script to load linker sequences (amino acid sequences) and their embeddings.
"""
import pandas as pd
import pickle
import torch
from pathlib import Path


def load_sequences(csv_path="data/total_dataset.csv"):
    """Load amino acid sequences from CSV file."""
    df = pd.read_csv(csv_path)
    print(f"Loaded {len(df)} sequences")
    print(f"Columns: {df.columns.tolist()}")
    return df


def load_embeddings(pkl_path):
    """Load embeddings from pickle file."""
    with open(pkl_path, "rb") as f:
        embeddings = pickle.load(f)
    
    # Check if it's a dictionary or tensor
    if isinstance(embeddings, dict):
        print(f"Loaded embeddings dictionary with {len(embeddings)} entries")
        print(f"Keys (first 5): {list(embeddings.keys())[:5]}")
        # Convert dict values to tensor if needed
        if embeddings:
            first_val = next(iter(embeddings.values()))
            print(f"First embedding shape: {first_val.shape if hasattr(first_val, 'shape') else type(first_val)}")
    elif hasattr(embeddings, 'shape'):
        print(f"Loaded embeddings tensor with shape: {embeddings.shape}")
    else:
        print(f"Loaded embeddings of type: {type(embeddings)}")
    
    return embeddings


def main():
    # Load sequences
    df = load_sequences()
    
    # Example: load embeddings for one dataset
    # Using mean embeddings as they're much smaller than full hidden states
    embedding_path = "data/embeddings_large/unique_insideout_tmds_pseudomonas_processed/mean_last_hidden_state_esm2_t48_15B_UR50D.pkl"
    embeddings = load_embeddings(embedding_path)
    
    # Display first few sequences
    print("\nFirst 5 sequences:")
    print(df[['ID', 'Organism', 'Gene Name', 'TMD sequence']].head())
    
    # Filter for Pseudomonas insideout sequences if needed to match embeddings
    pseudomonas_insideout = df[(df['Organism type'] == 'Pseudomonas') & 
                                (df['TMD orientation'] == 'insideout')]
    print(f"\nFiltered to {len(pseudomonas_insideout)} Pseudomonas insideout sequences")
    
    # Link sequences to embeddings
    # The embeddings can be either a tensor or a dictionary
    pseudomonas_insideout = pseudomonas_insideout.copy()
    
    if isinstance(embeddings, dict):
        print(f"\nEmbeddings dictionary with {len(embeddings)} entries")
        print(f"Number of sequences: {len(pseudomonas_insideout)}")
        
        # If embeddings are keyed by sequence or index, link them
        if len(embeddings) == len(pseudomonas_insideout):
            # Assuming the dict is ordered and matches the dataframe order
            pseudomonas_insideout['embedding'] = [embeddings[k] for k in list(embeddings.keys())[:len(pseudomonas_insideout)]]
            print("Successfully linked embeddings to sequences!")
        else:
            print(f"Note: Dictionary has {len(embeddings)} entries, dataframe has {len(pseudomonas_insideout)} rows")
            # Try to match by sequence if keys are sequences
            first_key = list(embeddings.keys())[0]
            if isinstance(first_key, str) and first_key in pseudomonas_insideout['TMD sequence'].values:
                pseudomonas_insideout['embedding'] = pseudomonas_insideout['TMD sequence'].map(embeddings)
                print("Linked embeddings by sequence matching!")
    
    elif isinstance(embeddings, torch.Tensor):
        print(f"\nEmbeddings tensor shape: {embeddings.shape}")
        print(f"Number of sequences: {len(pseudomonas_insideout)}")
        
        if len(embeddings) == len(pseudomonas_insideout):
            # Add embeddings to dataframe
            pseudomonas_insideout['embedding'] = list(embeddings.numpy())
            print("Successfully linked embeddings to sequences!")
        else:
            print(f"Warning: Mismatch between number of embeddings ({len(embeddings)}) and sequences ({len(pseudomonas_insideout)})")
    
    return df, embeddings, pseudomonas_insideout


if __name__ == "__main__":
    df, embeddings, linked_data = main()
