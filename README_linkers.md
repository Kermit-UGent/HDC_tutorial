# Linker Data Loading

This project contains scripts to load amino acid sequences (TMD linkers) and their ESM2 embeddings.

## Setup

### 1. Create the conda environment:
```bash
conda env create -f environment.yml
```

### 2. Activate the environment:
```bash
conda activate hdc_tutorial
```

## Usage

### Run the loading script:
```bash
python load_linkers.py
```

## Data Structure

- **Sequences**: `data/total_dataset.csv` contains 15,498 amino acid sequences with metadata:
  - ID, Organism, Gene Name
  - TMD sequence (the amino acid sequence)
  - TMD length, TMD orientation
  - Organism type, Group

- **Embeddings**: `data/embeddings_large/` contains ESM2 embeddings organized by:
  - Organism type (Pseudomonas, Rhodobacter, etc.)
  - Orientation (insideout, outsidein)
  - Two types of embeddings per dataset:
    - `mean_last_hidden_state_esm2_t48_15B_UR50D.pkl` - Mean pooled embeddings (smaller, 5120-dimensional vectors)
    - `last_hidden_state_esm2_t48_15B_UR50D.pkl` - Full sequence embeddings (larger)

## Script Functionality

The `load_linkers.py` script:
1. Loads all sequences from the CSV file
2. Loads embeddings from pickle files (requires PyTorch)
3. Filters sequences by organism type and orientation
4. Links embeddings to their corresponding sequences
5. Returns a pandas DataFrame with sequences and their embeddings

### Example output:
```python
df, embeddings, linked_data = main()

# df: Full dataset with all sequences
# embeddings: Dictionary or tensor of embeddings
# linked_data: Filtered dataframe with embeddings column added
```

Each embedding is a torch tensor of shape (1, 5120) representing the protein sequence in high-dimensional space.

## Dependencies

- Python 3.10
- PyTorch
- pandas
- numpy
- fair-esm (ESM protein language models)
