

#ifndef open_h 
#define open_h

# ifndef NO_TEST_OPENING
# define _testOpening(pt)	{if ((pt)==NULL){(void)fprintf(stderr,"   fopen() failed in file \"%s\" on line %d\n\n", __FILE__, __LINE__);exit(1);}}
# define testOpening(pt) _testOpening(pt)
# else
# define _testOpening(pt)
# define testOpening(pt)
# endif

#endif // open_h
