# Analyzing Relationship Between Programming Languages and Code Quality in Github
This repository contains artifacts for reproducibility.

## Getting Started
You'll need to setup a python3 and R enviroment.

### Prerequisites
Following libraries are required to run the provided files

```
pip install jupyter pandas sklearn spacy tqdm spacy-transformers
```

You will also need to aquire client_id and client_secret from GitHub to fetch some data.

You will also need to run the following command on terminal to download the pre-trained weights of the transformer model:
```
python -m spacy download en_trf_distilbertbaseuncased_lg
```

### Artifcat details
The following list explains as in which order the artifacts should be executed:
1) bigquery_query.txt
    1) Goto Google big query tool
    2) Set the SQL dialect as legacy
    3) Run the query provided in the text file on Google big query platform
    4) Save the result as language_repo.csv
2) 1_repo_list_downloading.ipynb
3) 2_fetching_repositories_ch.ipynb
4) 3_spacy_train_model.ipynb (Use CPU backend as the model does not train correctly on a GPU)
5) 4_commit_message.ipynb
6) 5_spacy_predict.ipynb
7) 6_bug_type_classification.ipynb
8) 7_regression_dataset_creation.ipynb

After running these files you can goto individual RQ questions and run the relevant R scripts to get the results

Start from step 4 if you want to reproduce the results of the paper. you just need dataset.csv to get started.
We have also provided the final csv's required to answer the RQs within each folder as executing the whole project is a time intensive task
