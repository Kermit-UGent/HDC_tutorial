"""
Script to link amino acid sequences with their embeddings and save as CSV files.
Creates two files:
1. sequences.csv - Contains id, sequence, and origin (bacterial/plant)
2. embeddings.csv - Contains the corresponding embeddings
"""
import pandas as pd
import pickle
import torch
import numpy as np
from pathlib import Path


def load_embeddings(pkl_path):
    """Load embeddings from pickle file."""
    with open(pkl_path, "rb") as f:
        embeddings = pickle.load(f)
    return embeddings


def process_embedding_dict(embeddings_dict):
    """Convert embedding dictionary to a list of numpy arrays."""
    embeddings_list = []
    for key in sorted(embeddings_dict.keys()):
        emb = embeddings_dict[key]
        # Convert to numpy and squeeze if necessary
        if isinstance(emb, torch.Tensor):
            emb = emb.squeeze().numpy()
        embeddings_list.append(emb)
    return embeddings_list


def main():
    # Load sequences
    print("Loading sequences from CSV...")
    df = pd.read_csv("data/total_dataset.csv")
    print(f"Total sequences: {len(df)}")
    
    # Define embedding paths
    embedding_paths = {
        'pseudomonas_insideout': 'data/embeddings_large/unique_insideout_tmds_pseudomonas_processed/mean_last_hidden_state_esm2_t48_15B_UR50D.pkl',
        'pseudomonas_outsidein': 'data/embeddings_large/unique_outsidein_tmds_pseudomonas_processed/mean_last_hidden_state_esm2_t48_15B_UR50D.pkl',
        'rhodobacter_insideout': 'data/embeddings_large/unique_insideout_tmds_rhodobacter_processed/mean_last_hidden_state_esm2_t48_15B_UR50D.pkl',
        'rhodobacter_outsidein': 'data/embeddings_large/unique_outsidein_tmds_rhodobacter_processed/mean_last_hidden_state_esm2_t48_15B_UR50D.pkl',
        'plant': 'data/embeddings_large/unique_plantcyps_tmds/mean_last_hidden_state_esm2_t48_15B_UR50D.pkl',
    }
    
    # Initialize lists to collect data
    all_sequences = []
    all_embeddings = []
    all_ids = []
    all_origins = []
    
    # Process bacterial sequences (Pseudomonas and Rhodobacter)
    for dataset_name, emb_path in embedding_paths.items():
        if 'plant' in dataset_name:
            continue  # Process plants separately
        
        print(f"\nProcessing {dataset_name}...")
        
        # Determine organism type and orientation
        if 'pseudomonas' in dataset_name:
            organism_type = 'Pseudomonas'
        elif 'rhodobacter' in dataset_name:
            organism_type = 'Rhodobacter'
        
        if 'insideout' in dataset_name:
            orientation = 'insideout'
        elif 'outsidein' in dataset_name:
            orientation = 'outsidein'
        
        # Filter dataframe for this specific dataset
        filtered_df = df[(df['Organism type'] == organism_type) & 
                        (df['TMD orientation'] == orientation)].copy()
        
        print(f"  Found {len(filtered_df)} sequences in CSV")
        
        # Load embeddings
        if Path(emb_path).exists():
            embeddings = load_embeddings(emb_path)
            
            if isinstance(embeddings, dict):
                embeddings_list = process_embedding_dict(embeddings)
                print(f"  Loaded {len(embeddings_list)} embeddings")
                
                # Verify counts match
                if len(embeddings_list) == len(filtered_df):
                    # Add to collections
                    for idx, (_, row) in enumerate(filtered_df.iterrows()):
                        all_ids.append(f"{dataset_name}_{idx}")
                        all_sequences.append(row['TMD sequence'])
                        all_origins.append('bacterial')
                        all_embeddings.append(embeddings_list[idx])
                    
                    print(f"  ✓ Successfully linked {len(filtered_df)} sequences")
                else:
                    print(f"  ✗ Warning: Mismatch - {len(embeddings_list)} embeddings vs {len(filtered_df)} sequences")
        else:
            print(f"  ✗ Embedding file not found: {emb_path}")
    
    # Process plant sequences
    print(f"\nProcessing plant sequences...")
    plant_df = df[df['Group'] == 'Plant'].copy()
    print(f"  Found {len(plant_df)} plant sequences in CSV")
    
    plant_emb_path = embedding_paths['plant']
    if Path(plant_emb_path).exists():
        plant_embeddings = load_embeddings(plant_emb_path)
        
        if isinstance(plant_embeddings, dict):
            plant_embeddings_list = process_embedding_dict(plant_embeddings)
            print(f"  Loaded {len(plant_embeddings_list)} embeddings")
            
            # Verify counts match
            if len(plant_embeddings_list) == len(plant_df):
                # Add to collections
                for idx, (_, row) in enumerate(plant_df.iterrows()):
                    all_ids.append(f"plant_{idx}")
                    all_sequences.append(row['TMD sequence'])
                    all_origins.append('plant')
                    all_embeddings.append(plant_embeddings_list[idx])
                
                print(f"  ✓ Successfully linked {len(plant_df)} sequences")
            else:
                print(f"  ✗ Warning: Mismatch - {len(plant_embeddings_list)} embeddings vs {len(plant_df)} sequences")
    else:
        print(f"  ✗ Embedding file not found: {plant_emb_path}")
    
    # Create DataFrames
    print(f"\n{'='*60}")
    print(f"Total sequences with embeddings: {len(all_sequences)}")
    print(f"  Bacterial: {sum(1 for o in all_origins if o == 'bacterial')}")
    print(f"  Plant: {sum(1 for o in all_origins if o == 'plant')}")
    
    # Sequences DataFrame
    sequences_df = pd.DataFrame({
        'id': all_ids,
        'sequence': all_sequences,
        'origin': all_origins
    })
    
    # Embeddings DataFrame (each row is one embedding vector)
    embeddings_array = np.array(all_embeddings)
    print(f"Embedding shape: {embeddings_array.shape}")
    
    # Create column names for embeddings
    embedding_columns = [f'emb_{i}' for i in range(embeddings_array.shape[1])]
    embeddings_df = pd.DataFrame(embeddings_array, columns=embedding_columns)
    embeddings_df.insert(0, 'id', all_ids)  # Add id column for reference
    
    # Save to CSV
    print(f"\nSaving to CSV files...")
    sequences_df.to_csv('data/sequences.csv', index=False)
    print(f"  ✓ Saved sequences.csv ({len(sequences_df)} rows)")
    
    embeddings_df.to_csv('data/embeddings.csv', index=False)
    print(f"  ✓ Saved embeddings.csv ({len(embeddings_df)} rows, {len(embedding_columns)} embedding dimensions)")
    
    print(f"\n{'='*60}")
    print("Done!")
    print("\nFiles created:")
    print("  - sequences.csv: id, sequence, origin")
    print("  - embeddings.csv: id, emb_0, emb_1, ..., emb_5119")
    
    return sequences_df, embeddings_df


if __name__ == "__main__":
    sequences_df, embeddings_df = main()
