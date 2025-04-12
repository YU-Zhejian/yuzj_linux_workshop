/*!
 * @file stupid.h
 * @author YU ZJ
 * @brief The API of libstupid.
 * @version 0.1
 * @date 2025-04-13
 * 
 * @copyright Copyright (c) 2025
 * 
 * API of libstupid.
 */
#ifndef STUPID_H
#define STUPID_H

/*!
 * @def CEU_PARAMS
 * @brief A macro used to wrap function prototypes for compatibility isues of non-ANSI compiler.
 *
 * This macro would let the compilers that don't understand ANSI C prototypes still work,
 * while ANSI C compilers can issue warnings about type mismatches.
 *
 * You may pre-define this macro if you know your compiler well.
 * Otherwise its definition will be based on testing of compiler-specific pre-defined macros.
 *
 * @see https://www.gnu.org/software/libtool/manual/html_node/C-header-files.html
 */
#ifndef CEU_PARAMS
#if defined __STDC__ || defined _AIX             \
    || (defined __mips && defined _SYSTYPE_SVR4) \
    || defined WIN32 || defined __cplusplus
#define CEU_PARAMS(protos) protos
#else
#define CEU_PARAMS(protos) ()
#endif
#endif

#ifdef __cplusplus
extern "C" {
#endif

/*!
 * Get the sum of `a` and `b`.
 *
 * @param a As described.
 * @param b As described.
 * @return As described.
 */
int stupid_add CEU_PARAMS((int a, int b));

#ifdef __cplusplus
}
#endif

#endif
