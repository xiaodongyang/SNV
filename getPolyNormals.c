#include "mex.h"
#include "matrix.h"

void mexFunction(int nout, mxArray *out[], int nin, const mxArray *in[]) {
	// index of input and output variables
	enum {DX, DY, DT, LR, LC, LT};
	enum {PN, ROW, COL, FRM};

	// input matrix dimensions and pointers
	const int* ndims = mxGetDimensions(in[DX]);
	int nrows = ndims[0];
	int ncols = ndims[1];
	int nfrms = ndims[2];

	const double* dx = mxGetPr(in[DX]);
	const double* dy = mxGetPr(in[DY]);
	const double* dt = mxGetPr(in[DT]);

	// local neighborhood size
	int lr = (int) *mxGetPr(in[LR]);
	int lc = (int) *mxGetPr(in[LC]);
	int lt = (int) *mxGetPr(in[LT]);

	// iteration index and range
	int ridx = 0; int cidx = 0;
	int r, c, t, ir, ic, it;

	int rs = lr / 2; int re = nrows - (lr / 2);
	int cs = lc / 2; int ce = ncols - (lc / 2);
	int ts = lt / 2; int te = nfrms - (lt / 2);
	int lrs = -lr / 2; int lre = lr / 2;
	int lcs = -lc / 2; int lce = lc / 2;
	int lts = -lt / 2; int lte = lt / 2;

	// output matrix dimensions and pointers
	int nnorms = 3 * lr * lc * lt;
	int nelems = (nrows - 2 * (lr / 2)) * (ncols - 2 * (lc / 2)) * (nfrms - 2 * (lt / 2));

	double *pn, *row, *col, *frm;

	// check argument numbers
	if (nin < 6)
		mexErrMsgTxt("At least six arguments are required!");
	else if (nout > 4)
		mexErrMsgTxt("Too many output arguments!");

	// initialize ouput matrix without nullifying
	out[PN] = mxCreateDoubleMatrix(0, 0, mxREAL);
	mxSetM(out[PN], nelems);
	mxSetN(out[PN], nnorms);
	mxSetData(out[PN], mxMalloc(sizeof(double) * nelems * nnorms));
	pn = mxGetPr(out[PN]);

	out[ROW] = mxCreateDoubleMatrix(0, 0, mxREAL);
	mxSetM(out[ROW], nelems);
	mxSetN(out[ROW], 1);
	mxSetData(out[ROW], mxMalloc(sizeof(double) * nelems));
	row = mxGetPr(out[ROW]);

	out[COL] = mxCreateDoubleMatrix(0, 0, mxREAL);
	mxSetM(out[COL], nelems);
	mxSetN(out[COL], 1);
	mxSetData(out[COL], mxMalloc(sizeof(double) * nelems));
	col = mxGetPr(out[COL]);

	out[FRM] = mxCreateDoubleMatrix(0, 0, mxREAL);
	mxSetM(out[FRM], nelems);
	mxSetN(out[FRM], 1);
	mxSetData(out[FRM], mxMalloc(sizeof(double) * nelems));
	frm = mxGetPr(out[FRM]);

	// get polynormals
	for (r = rs; r < re; ++r) {
		for (c = cs; c < ce; ++c) {
			for (t = ts; t < te; ++t) {
				cidx = 0;

				// from dx
				for (it = lts; it <= lte; ++it) {
					for (ic = lcs; ic <= lce; ++ic) {
						for (ir = lrs; ir <= lre; ++ir) {
							pn[ridx + cidx++ * nelems] = dx[(t + it) * (nrows * ncols) + (c + ic) * nrows + (r + ir)];
						}
					}
				}

				// from dy
				for (it = lts; it <= lte; ++it) {
					for (ic = lcs; ic <= lce; ++ic) {
						for (ir = lrs; ir <= lre; ++ir) {
							pn[ridx + cidx++ * nelems] = dy[(t + it) * (nrows * ncols) + (c + ic) * nrows + (r + ir)];
						}
					}
				}

				// from dt
				for (it = lts; it <= lte; ++it) {
					for (ic = lcs; ic <= lce; ++ic) {
						for (ir = lrs; ir <= lre; ++ir) {
							pn[ridx + cidx++ * nelems] = dt[(t + it) * (nrows * ncols) + (c + ic) * nrows + (r + ir)];
						}
					}
				}

				// fill in position
				row[ridx] = r + 1;
				col[ridx] = c + 1;
				frm[ridx] = t + 1;

				// update row index
				++ridx;
			}
		}
	}

	return;
}