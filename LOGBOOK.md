# ANa Logbook

## Goal 
Create a language model which can be prompted with a specific topic (e.g machine learning) and will return a tweet length response about the topic

## Timeline
### 2023-05-06 07:58 EST: [Kadeem] Automating Infrastrcture Management - Setup
Taking a step away from modeling to automate the provisioning of infrastrcture in Azure. Hopes are that this will make it easy to experiment with different resources as the project goes through different iterations or to just get a clean slate whenever one is needed. The az command has been a godsend and I'm interested to continue learning and using it more.

### 2023-04-29 01:09 EST: [Kadeem] Initial NGram Model
Lost a few logbook entries due to carelessness, however, I've successfully created the initial version of the ngram model. This implementation is inefficient though, especially with regards to memory, as it requires a tensor of VOCABULARY_SIZE ^ NGRAM_SIZE to store the ngram probabilities. In addition to some refactoring, documentation and general cleanup this will be addressed.

### 2023-03-19 17:08 EST: [Kadeem] Automating common workflows
For over 3 weeks I've been working on automating the workflows for the project. Initially this was in the form of several scripts stored alongside the components they operated on almost in a package by feature style (e.g storing scripts for building and starting the api along with the source for the api itself). Over time I found it better to just move everything to a central directory accessed using a singular script with branching commands (think docker cli). Need to return to working on the model, so will target completing the scripts and cleaning up the directory in the next few days

### 2023-03-04 07:29 EST: [Kadeem] Implementing CI Workflow - Build Agent Container
Taking steps toward automating the application deployment after the first manual deployment, starting out with a simple build container. Should go a long way towards preventing build errors that would occur if it was built locally without the cost of provisioning a build server.

Using this time as well to establish some overall 'best' practices so that it's easier to track the application development over time. Ultimately the goal here is to create a comprehensive history of changes to the application with appropriate detail and justification (or at least the though process that went into it).

### 2023-02-20 18:57 EST: [Kadeem] Setting up project in Azure
Got a dead simple version of the application running end to end in Azure. It's a simple character level bigram model so performance isn't great but it's a fun start. UI is even simpler with just a button to send an HTTP request to a REST API wrapping the model. 

Considerations for next steps:
- Model: Change to word level n-gram model, may be able to use simple BOW representation to start but could explore other alternatives
- UI: Noticed some display issues when changing resolution on the frontend so will need to take resolution into consideration when sizing the UI elements
- Infrastructure: Lots of work to be done here, need a clear deployment procedure (building, packaging etc..), took some shortcuts installing required software directly onto the VM, may need a hard reset of that machine