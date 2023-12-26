# ANa Logbook

## Goal 
Develop an autonomous agent that can interpret tasks described in natural language and autonomously plan and execute these tasks effectively

## Timeline
---
Update this entry
### Entry #7 [2023-12-18 19:36] Automating Virtual Machine Setup For Model Traning
#### Progress
- Refactored the 'setup' script to improve readability and added additional error handling
- Automated the creation of management groups during setup 

#### Challenges
- Azure CLI has a bit of a learning curve but not too bad, suspect the hardest part will be configuring the VM for model training inside docker container

#### Next Steps
- Create a README document describing the setup required in Azure to use the infra setup & teardown scripts

#### Technical Notes & Reflections
The Azure CLI doesn't allow you to create a new subscription (likely because you have to sign an agreement) so the subscription will need to exist before you can use the infrastructure setup script. P.S Not even a day went by and I messed up the formatting of the heredoc usage message in the setup script so it's been changed to be a bit easier to work with.

NOTE: I'll need to update the previous changelog entries to keep them consistent, going forward any updates to the format will be reflected in the logbook.

---
### Entry #7 [2023-12-18 19:36] Automating Virtual Machine Setup For Model Traning
#### Progress
- Refactored the 'setup' script to improve readability and added additional error handling
- Automated the creation of management groups during setup 

#### Challenges
- Azure CLI has a bit of a learning curve but not too bad, suspect the hardest part will be configuring the VM for model training inside docker container

#### Next Steps
- Automate the creation of the resource groups and assign them to the managment group
- Automate the creation of the virtual machine 
- Continue to improve the setup script

#### Technical Notes & Reflections
Need to make a note of all of the azure client extensions that I installed to execute the commands in the scripts. I also wonder if my heredoc approach in the script should be changed, I had to use a combination of tabs and spaces to get it looking how I wanted but I fear it's brittle and prone to 'accidental' formatting errors.

NOTE: I'll need to update the previous changelog entries to keep them consistent, going forward any updates to the format will be reflected in the logbook.

---
### Entry #6 || 2023-05-14 07:07 EST: [Kadeem] Representing N-Grams Efficiently
As highlighted in entry #4, the primary factor hindering the model's current performance is the restriction on the maximum ngram size allowed. This limitation arises from the representation of ngram probabilities in the current model's architecture.

Consider the case of a character level, trigram model, derived from a corpus of vocabulary size 26. Given the model's current implementation, a tensor of shape `(26, 26, 26)` will be used to represent the probability matrix, resulting in `((vocab_size ^ ngram_size) * 4)` bytes of memory usage. With each vector at index `[i,j]` storing the probability distribution of the next token after tokens `i` and `j` in the vocabulary.

We need a model architecture that allows the ngram size to increase without resulting in a corresponding increase in memory consumption. The following outlines my initial thoughts on how to approach this:
1. Represent each ngram using bag of words representation 
2. Create a deep neural network (simple perceptron) that accepts the BoW ngram as input 
3. Train the model on the training set to predict the next likely token given an ngram
4. Determine and apply an evaluation metric for generated text ensuring that overfitting does not occur

### Entry #5 || 2023-05-06 07:58 EST: [Kadeem] Automating Infrastrcture Management - Setup
Taking a step away from modeling to automate the provisioning of infrastrcture in Azure. Hopes are that this will make it easy to experiment with different resources as the project goes through different iterations or to just get a clean slate whenever one is needed. The az command has been a godsend and I'm interested to continue learning and using it more.

### Entry #4 || 2023-04-29 01:09 EST: [Kadeem] Initial NGram Model
Lost a few logbook entries due to carelessness, however, I've successfully created the initial version of the ngram model. This implementation is inefficient though, especially with regards to memory, as it requires a tensor of VOCABULARY_SIZE ^ NGRAM_SIZE to store the ngram probabilities. In addition to some refactoring, documentation and general cleanup this will be addressed.

### Entry #3 || 2023-03-19 17:08 EST: [Kadeem] Automating common workflows
For over 3 weeks I've been working on automating the workflows for the project. Initially this was in the form of several scripts stored alongside the components they operated on almost in a package by feature style (e.g storing scripts for building and starting the api along with the source for the api itself). Over time I found it better to just move everything to a central directory accessed using a singular script with branching commands (think docker cli). Need to return to working on the model, so will target completing the scripts and cleaning up the directory in the next few days

### Entry #2 || 2023-03-04 07:29 EST: [Kadeem] Implementing CI Workflow - Build Agent Container
Taking steps toward automating the application deployment after the first manual deployment, starting out with a simple build container. Should go a long way towards preventing build errors that would occur if it was built locally without the cost of provisioning a build server.

Using this time as well to establish some overall 'best' practices so that it's easier to track the application development over time. Ultimately the goal here is to create a comprehensive history of changes to the application with appropriate detail and justification (or at least the though process that went into it).

### Entry #1 || 2023-02-20 18:57 EST: [Kadeem] Setting up project in Azure
Got a dead simple version of the application running end to end in Azure. It's a simple character level bigram model so performance isn't great but it's a fun start. UI is even simpler with just a button to send an HTTP request to a REST API wrapping the model. 

Considerations for next steps:
- Model: Change to word level n-gram model, may be able to use simple BOW representation to start but could explore other alternatives
- UI: Noticed some display issues when changing resolution on the frontend so will need to take resolution into consideration when sizing the UI elements
- Infrastructure: Lots of work to be done here, need a clear deployment procedure (building, packaging etc..), took some shortcuts installing required software directly onto the VM, may need a hard reset of that machine
