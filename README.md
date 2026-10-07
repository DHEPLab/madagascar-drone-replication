# Wings of Access — Madagascar Drone Cluster RCT Replication Package

## Repository layout

```
madagascar-drone-replication/
├── data/
│   └── [public-use data files required by the replication scripts]
├── code/
│   ├── drone_med_public_table1_replication.py
│   └── drone_med_public_table2_replication.py
└── output/
    └── [replicated Table 1 and Table 2 outputs]

```

## How to run

### 1. Place the data files.
Download the required public-use datasets and place them in the data/ folder.
### 2. Install the required Python packages.
pip install pandas numpy statsmodels scipy
### 3. Replicate Table 1.
python code/drone_med_public_table1_replication.py \
  --data-dir . \
  --output-dir output
### 4. Replicate Table 2.
python code/drone_med_public_table2_replication.py \
  --data-dir data \
  --output-dir output

The replicated table outputs are written to the output/ folder.

## Replication scripts
drone_med_public_table1_replication.py reproduces Table 1 using the public-use data.
drone_med_public_table2_replication.py reproduces the Table 2 ANCOVA and difference-in-differences estimates using the public-use data.

No original or restricted-access data are required to run these replication scripts.
