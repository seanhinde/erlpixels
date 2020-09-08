#include "erl_nif.h"
#include <string.h>
#include "ext/lodepng.h"

#define SEPARATE_ALPHA 1

static ERL_NIF_TERM _png_result(ErlNifEnv *env, unsigned error, unsigned char *image_data, unsigned width, unsigned height, unsigned opts) {

    if (error) {
        // printf("error %u: %s\n", error, lodepng_error_text(error));
        return enif_make_tuple3(
            env,
            enif_make_atom(env, "error"),
            enif_make_int(env, error),
            enif_make_string(env, lodepng_error_text(error), ERL_NIF_LATIN1)
            );
    }

    ERL_NIF_TERM bindata_term;
    ERL_NIF_TERM alphadata_term;
    unsigned char * bindata_buf;
    unsigned char * alphadata_buf;

    if (opts & SEPARATE_ALPHA) {
        bindata_buf = enif_make_new_binary(env, width * height * 3, &bindata_term);
        alphadata_buf = enif_make_new_binary(env, width * height, &alphadata_term);
        for (int y=0; y<height; y++) {
            for (int x=0; x<width; x++) {
                bindata_buf[y * width * 3 + x * 3 + 0] = image_data[y * width * 4 + x * 4 + 0];
                bindata_buf[y * width * 3 + x * 3 + 1] = image_data[y * width * 4 + x * 4 + 1];
                bindata_buf[y * width * 3 + x * 3 + 2] = image_data[y * width * 4 + x * 4 + 2];
                alphadata_buf[y * width + x]           = image_data[y * width * 4 + x * 4 + 3];
            }
        }
        free(image_data);

        return enif_make_tuple4(
            env,
            enif_make_int(env, width),
            enif_make_int(env, height),
            bindata_term,
            alphadata_term
            );
    } else {
        bindata_buf = enif_make_new_binary(env, width * height * 4, &bindata_term);
        memcpy(bindata_buf, image_data, width * height * 4);
        free(image_data);

        return enif_make_tuple3(
            env,
            enif_make_int(env, width),
            enif_make_int(env, height),
            bindata_term
            );
    }
}

ERL_NIF_TERM decode_png(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    ErlNifBinary binary;
    unsigned opts;

    if (!enif_inspect_iolist_as_binary(env, argv[0], &binary)) {
        return enif_make_badarg(env);
    }

    if (!enif_get_uint(env, argv[1], &opts)) {
        return enif_make_badarg(env);
    }

    unsigned error;
    unsigned width = 0, height = 0;
    unsigned char* image_data = 0;

    error = lodepng_decode32(&image_data, &width, &height, binary.data, binary.size);
    return _png_result(env, error, image_data, width, height, opts);
}