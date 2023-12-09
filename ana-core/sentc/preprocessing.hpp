#include <string>
#include <map>
#include <vector> 

#include <torch/script.h>


namespace senti {
    std::vector<torch::jit::IValue> to_batch(std::vector<unsigned short> tokens, unsigned short vocab_size);

    struct Tokenizer {
        std::map<std::string, unsigned short> token_by_id;

        Tokenizer(std::string path);
        std::vector<unsigned short> tokenize(std::string text);
        std::size_t get_vocab_size();
    };
}