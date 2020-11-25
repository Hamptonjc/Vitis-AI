#include <pybind11/pybind11.h>
#include <pybind11/numpy.h>
#include <iostream>
#include <dpu4rnn.hpp>

namespace py = pybind11;

static char* array_to_pointer(py::array_t<int16_t>& a) {
  char* p = (char*)a.mutable_data();
  return p;
}

PYBIND11_MODULE(dpu4rnn_py, m) {
  m.doc() = "lstm dpu4rnn";
  py::class_<dpu4rnn, std::unique_ptr<dpu4rnn, py::nodelete>> (m, "dpu4rnn")
	  .def_static("create",
           &dpu4rnn::create,
	    py::arg("model_name"), py::arg("device_id")=0)
          .def("run",
          [](dpu4rnn* self,
	     py::array_t<int16_t> input,
	     int in_size,
	     py::array_t<int16_t> output,
	     int frame_num,
	     int batch){
	    char* input_p = array_to_pointer(input);
	    char* output_p = array_to_pointer(output);
	    self->run(input_p, in_size, output_p, frame_num, batch);
	    }, py::arg("input"), py::arg("in_size"), py::arg("output"),
               py::arg("frame_num"), py::arg("batch") = 1
	    )
	  .def("getBatch",
		&dpu4rnn::getBatch);

}
