#include "erl_nif.h"
#include "erlpixels_nif.h"

// Let's define the array of ErlNifFunc beforehand:
static ErlNifFunc nif_funcs[] = {
    // {erl_function_name, erl_function_arity, c_function}
    {"decode_png", 2, decode_png},
    {"decode_jpeg", 2, decode_jpeg}
};

ERL_NIF_INIT(erlpixels_nif, nif_funcs, NULL, NULL, NULL, NULL)