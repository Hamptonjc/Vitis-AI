#pragma once

#include <string>
#include <vector>
#include <mutex>
#include <vart/runner.hpp>
#include <xir/graph/graph.hpp>

#include "../include/dpu4rnn.hpp"

class dpu4rnnImp : public dpu4rnn {
 public:
  dpu4rnnImp(const std::string model_name, const int device_id = 0);
  virtual ~dpu4rnnImp();

  virtual void run(const char* input, int in_size, char* output,
		  int frame_num, int batch = 1) override;
  virtual int getBatch() override;

 private:
  void set(int batch, int frames, int in_len, int out_len) {
    idims_ = {batch, frames, in_len, 2};
    odims_ = {batch, frames, out_len, 2};
  };

  std::vector<int32_t> get_input_dims() {return idims_;};
  std::vector<int32_t> get_output_dims() {return odims_;};

 private:
  std::shared_ptr<xir::Graph> fakegraph;
  xir::Subgraph* rs;
  std::unique_ptr<vart::Runner> runner_;

  int device_id_;
  int batch_;
  std::string model_name_;

  std::vector<int32_t> idims_;
  std::vector<int32_t> odims_;
  std::vector<char> model_;
  
  std::vector<char> out_;

  std::mutex mtx;

  static const std::string xclbin_path_;
  static const std::vector<std::string> model_type_;
};

