require 'formula'

class Libscarab < Formula
  homepage 'https://hcrypt.com/scarab-library/'
  url 'https://hcrypt.com/downloads/libScarab-1.0.0.zip'
  sha1 '3d33e04b50298187861eaf598dac3698a391424a'

  depends_on 'gmp'
  depends_on 'flint1'

  def patches
    # build shared and static objects
    DATA
  end

  def install
    system "make"
    include.install Dir["fhe"]
    lib.install "libscarab.dylib", "libscarab.a"
    bin.install "integer-fhe"
  end

  def test
    system "#{bin}/integer-fhe"
  end
end

__END__
diff --git a/Makefile b/Makefile
index 15ebdea..cca80ea 100644
--- a/Makefile
+++ b/Makefile
@@ -1,15 +1,22 @@
 CC       = gcc
 CFLAGS   = -Wall -g3 -ggdb -std=c99 -I/opt/local/include
 LDFLAGS += -lgmp -lflint
+LINKER   = ar
 SOURCE   = $(shell find * -name '*.c')
 OBJECTS  = $(SOURCE:.c=.o)
 .PHONY:    clean

-all: integer-fhe
+all: integer-fhe libscarab.dylib libscarab.a

 integer-fhe: $(OBJECTS)
 	$(CC) -o integer-fhe $^ $(LDFLAGS)

+libscarab.dylib: $(OBJECTS)
+	$(CC) -shared -o libscarab.dylib $^ $(LDFLAGS)
+
+libscarab.a: $(OBJECTS)
+	$(LINKER) rcs libscarab.a $^
+
 clean:
-	rm -f $(OBJECTS) integer-fhe
+	rm -f $(OBJECTS) integer-fhe libscarab.dylib libscarab.a

diff --git a/integer-fhe.c b/integer-fhe.c
index 7934ff8..4228d9c 100644
--- a/integer-fhe.c
+++ b/integer-fhe.c
@@ -6,7 +6,7 @@
  *
  */
 
-#include "integer-fhe.h"
+#include "fhe/integer-fhe.h"
 #undef DEBUG
 
 #ifdef DETERMINISTIC
diff --git a/test.h b/test.h
index 422dbc4..67d65a6 100644
--- a/test.h
+++ b/test.h
@@ -13,7 +13,7 @@
 #include <stdlib.h>
 #include <stdio.h>
 #include <assert.h>
-#include "integer-fhe.h"
+#include "fhe/integer-fhe.h"
 
 #define RUNS 50
 #define KEYRUNS 10
diff --git a/types.c b/types.c
index a9df403..111f8fa 100644
--- a/types.c
+++ b/types.c
@@ -7,7 +7,7 @@
  *
  */
 
-#include "types.h"
+#include "fhe/types.h"
 
 
 /** memory management **/
diff --git a/util.c b/util.c
index e859f49..704cfaa 100644
--- a/util.c
+++ b/util.c
@@ -7,7 +7,7 @@
  *
  */
 
-#include "util.h"
+#include "fhe/util.h"
 
 int
 min(int a, int b)
diff --git a/fhe/integer-fhe.h b/fhe/integer-fhe.h
new file mode 100644
index 0000000..71bee48
--- /dev/null
+++ b/fhe/integer-fhe.h
@@ -0,0 +1,39 @@
+/*
+ *  keygen.h
+ *  integer-fhe
+ *
+ *  Created by Henning Perl on 01.03.10.
+ *
+ */
+
+#pragma once
+#ifndef INTEGER_FHE_H
+#define INTEGER_FHE_H
+
+#include <gmp.h>
+#include <assert.h>
+#include <fmpz_poly.h>
+#include <F_mpz_mod_poly.h>
+#include "types.h"
+#include "parameters.h"
+#include "util.h"
+
+/** main function **/
+
+void fhe_keygen(fhe_pk_t pk, fhe_sk_t sk);
+
+void fhe_encrypt(mpz_t c, fhe_pk_t pk, int m);
+
+int  fhe_decrypt(mpz_t c, fhe_sk_t sk);
+
+void fhe_recrypt(mpz_t c, fhe_pk_t pk);
+
+void fhe_add(mpz_t res, mpz_t a, mpz_t b, fhe_pk_t pk);
+
+void fhe_mul(mpz_t res, mpz_t a, mpz_t b, fhe_pk_t pk);
+
+void fhe_fulladd(mpz_t sum, mpz_t c_out, mpz_t a, mpz_t b, mpz_t c_in, fhe_pk_t pk);
+
+void fhe_halfadd(mpz_t sum, mpz_t c_out, mpz_t a, mpz_t b, fhe_pk_t pk);
+
+#endif
\ No newline at end of file
diff --git a/fhe/parameters.h b/fhe/parameters.h
new file mode 100644
index 0000000..25f4cbc
--- /dev/null
+++ b/fhe/parameters.h
@@ -0,0 +1,23 @@
+/*
+ *  parameters.h
+ *  integer-fhe
+ *
+ *  Created by Henning Perl on 25.11.10.
+ *  Copyright 2010 Henning Perl. All rights reserved.
+ *
+ */
+
+#pragma once
+#ifndef PARAMETERS_H
+#define PARAMETERS_H
+
+#define N 8
+#define MU 4
+//#define NU 2**256;
+#define LOG_NU 384
+#define S1 8
+#define S2 5
+#define T  5 // Ceiling[Log[2, S2]] + 2
+#define S  3 // Floor[Log[2, s2]] + 1
+
+#endif
\ No newline at end of file
diff --git a/fhe/types.h b/fhe/types.h
new file mode 100644
index 0000000..356977f
--- /dev/null
+++ b/fhe/types.h
@@ -0,0 +1,46 @@
+/*
+ *  types.h
+ *  integer-fhe
+ *
+ *  Created by Henning Perl on 25.11.10.
+ *  Copyright 2010 Henning Perl. All rights reserved.
+ *
+ */
+
+#pragma once
+#ifndef TYPES_H
+#define TYPES_H
+
+#include <stdio.h>
+#include <gmp.h>
+#include "parameters.h"
+
+/** type defs **/
+typedef struct {
+       mpz_t p, alpha;
+       mpz_t c[S1], B[S1];
+} _fhe_pk;
+typedef _fhe_pk fhe_pk_t[1];
+
+typedef struct {
+       mpz_t p, B;
+} _fhe_sk;
+typedef _fhe_sk fhe_sk_t[1];
+
+/** memory management **/
+
+void fhe_pk_init(fhe_pk_t pk);
+
+void fhe_pk_clear(fhe_pk_t pk);
+
+void fhe_sk_init(fhe_sk_t sk);
+
+void fhe_sk_clear(fhe_sk_t sk);
+
+/** output **/
+
+void fhe_pk_print(fhe_pk_t pk);
+
+void fhe_sk_print(fhe_sk_t sk);
+
+#endif
\ No newline at end of file
diff --git a/fhe/util.h b/fhe/util.h
new file mode 100644
index 0000000..6ec6572
--- /dev/null
+++ b/fhe/util.h
@@ -0,0 +1,39 @@
+/*
+ *  util.h
+ *  integer-fhe
+ *
+ *  Created by Henning Perl on 27.11.10.
+ *  Copyright 2010 Henning Perl. All rights reserved.
+ *
+ */
+
+#pragma once
+#ifndef UTIL_H
+#define UTIL_H
+
+#include <gmp.h>
+#include <fmpz_poly.h>
+#include <F_mpz_mod_poly.h>
+
+int min(int a, int b);
+
+void fmpz_poly_to_F_mpz_mod_poly(F_mpz_mod_poly_t out, fmpz_poly_t in);
+
+void fmpz_poly_rand_coeff_even(fmpz_poly_t poly, int n, ulong length, gmp_randstate_t* state);
+
+int fmpz_probab_prime_p(fmpz_t n, int reps);
+
+void F_mpz_mod_poly_gcd_euclidean(F_mpz_mod_poly_t res, F_mpz_mod_poly_t poly1, F_mpz_mod_poly_t poly2);
+
+static inline
+void _F_mpz_mod_poly_attach(F_mpz_mod_poly_t out, const F_mpz_mod_poly_t in)
+{
+       out->coeffs = in->coeffs;
+       out->length = in->length;
+       out->alloc = in->alloc;
+       *(out->P) = *(in->P);
+}
+
+void F_mpz_mod_poly_make_monic(F_mpz_mod_poly_t output, F_mpz_mod_poly_t pol);
+
+#endif
\ No newline at end of file
diff --git a/integer-fhe.h b/integer-fhe.h
deleted file mode 100644
index 71bee48..0000000
--- a/integer-fhe.h
+++ /dev/null
@@ -1,39 +0,0 @@
-/*
- *  keygen.h
- *  integer-fhe
- *
- *  Created by Henning Perl on 01.03.10.
- *
- */
-
-#pragma once
-#ifndef INTEGER_FHE_H
-#define INTEGER_FHE_H
-
-#include <gmp.h>
-#include <assert.h>
-#include <fmpz_poly.h>
-#include <F_mpz_mod_poly.h>
-#include "types.h"
-#include "parameters.h"
-#include "util.h"
-
-/** main function **/
-
-void fhe_keygen(fhe_pk_t pk, fhe_sk_t sk);
-
-void fhe_encrypt(mpz_t c, fhe_pk_t pk, int m);
-
-int  fhe_decrypt(mpz_t c, fhe_sk_t sk);
-
-void fhe_recrypt(mpz_t c, fhe_pk_t pk);
-
-void fhe_add(mpz_t res, mpz_t a, mpz_t b, fhe_pk_t pk);
-
-void fhe_mul(mpz_t res, mpz_t a, mpz_t b, fhe_pk_t pk);
-
-void fhe_fulladd(mpz_t sum, mpz_t c_out, mpz_t a, mpz_t b, mpz_t c_in, fhe_pk_t pk);
-
-void fhe_halfadd(mpz_t sum, mpz_t c_out, mpz_t a, mpz_t b, fhe_pk_t pk);
-
-#endif
\ No newline at end of file
diff --git a/parameters.h b/parameters.h
deleted file mode 100644
index 25f4cbc..0000000
--- a/parameters.h
+++ /dev/null
@@ -1,23 +0,0 @@
-/*
- *  parameters.h
- *  integer-fhe
- *
- *  Created by Henning Perl on 25.11.10.
- *  Copyright 2010 Henning Perl. All rights reserved.
- *
- */
-
-#pragma once
-#ifndef PARAMETERS_H
-#define PARAMETERS_H
-
-#define N 8
-#define MU 4
-//#define NU 2**256;
-#define LOG_NU 384
-#define S1 8
-#define S2 5
-#define T  5 // Ceiling[Log[2, S2]] + 2
-#define S  3 // Floor[Log[2, s2]] + 1
-
-#endif
\ No newline at end of file
diff --git a/types.h b/types.h
deleted file mode 100644
index 356977f..0000000
--- a/types.h
+++ /dev/null
@@ -1,46 +0,0 @@
-/*
- *  types.h
- *  integer-fhe
- *
- *  Created by Henning Perl on 25.11.10.
- *  Copyright 2010 Henning Perl. All rights reserved.
- *
- */
-
-#pragma once
-#ifndef TYPES_H
-#define TYPES_H
-
-#include <stdio.h>
-#include <gmp.h>
-#include "parameters.h"
-
-/** type defs **/
-typedef struct {
-	mpz_t p, alpha;
-	mpz_t c[S1], B[S1];
-} _fhe_pk;
-typedef _fhe_pk fhe_pk_t[1];
-
-typedef struct {
-	mpz_t p, B;
-} _fhe_sk;
-typedef _fhe_sk fhe_sk_t[1];
-
-/** memory management **/
-
-void fhe_pk_init(fhe_pk_t pk);
-
-void fhe_pk_clear(fhe_pk_t pk);
-
-void fhe_sk_init(fhe_sk_t sk);
-
-void fhe_sk_clear(fhe_sk_t sk);
-
-/** output **/
-
-void fhe_pk_print(fhe_pk_t pk);
-
-void fhe_sk_print(fhe_sk_t sk);
-
-#endif
\ No newline at end of file
diff --git a/util.h b/util.h
deleted file mode 100644
index 6ec6572..0000000
--- a/util.h
+++ /dev/null
@@ -1,39 +0,0 @@
-/*
- *  util.h
- *  integer-fhe
- *
- *  Created by Henning Perl on 27.11.10.
- *  Copyright 2010 Henning Perl. All rights reserved.
- *
- */
-
-#pragma once
-#ifndef UTIL_H
-#define UTIL_H
-
-#include <gmp.h>
-#include <fmpz_poly.h>
-#include <F_mpz_mod_poly.h>
-
-int min(int a, int b);
-
-void fmpz_poly_to_F_mpz_mod_poly(F_mpz_mod_poly_t out, fmpz_poly_t in);
-
-void fmpz_poly_rand_coeff_even(fmpz_poly_t poly, int n, ulong length, gmp_randstate_t* state);
-
-int fmpz_probab_prime_p(fmpz_t n, int reps);
-
-void F_mpz_mod_poly_gcd_euclidean(F_mpz_mod_poly_t res, F_mpz_mod_poly_t poly1, F_mpz_mod_poly_t poly2);
-
-static inline
-void _F_mpz_mod_poly_attach(F_mpz_mod_poly_t out, const F_mpz_mod_poly_t in)
-{
-	out->coeffs = in->coeffs;
-	out->length = in->length;
-	out->alloc = in->alloc;
-	*(out->P) = *(in->P);
-}
-
-void F_mpz_mod_poly_make_monic(F_mpz_mod_poly_t output, F_mpz_mod_poly_t pol);
-
-#endif
\ No newline at end of file

