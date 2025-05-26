struct Pix;

typedef struct Pix PIX;

/*!
 *  pixRead()
 *
 *      Input:  filename (with full pathname or in local directory)
 *      Return: pix if OK; null on error
 */
PIX* pixRead(const char  *filename);

 /*!
 *  pixDestroy()
 *
 *      Input:  &pix <will be nulled>
 *      Return: void
 *
 *  Notes:
 *      (1) Decrements the ref count and, if 0, destroys the pix.
 *      (2) Always nulls the input ptr.
 */
void pixDestroy(PIX  **ppix);