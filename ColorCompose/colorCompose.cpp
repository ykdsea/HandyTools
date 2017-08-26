#include <stdio.h>


static bool formulaCaluate = false;

enum BlendMode{
	PreMultiplied = 0,
	Coverage = 1,
	NoneBlend = 2
};

struct Color {
	float R;
	float G;
	float B;
	float Alpha;
};

struct ComposeConfig{
	BlendMode blend;
	float gA;
};


ComposeConfig testcfgs[] = {
	//1 ~ 3
	{PreMultiplied, 0.29}, {PreMultiplied, 1.0},
	{PreMultiplied, 0.29}, {Coverage, 1.0},
	{PreMultiplied, 0.29}, {NoneBlend, 1.0},

	//4 ~ 6
	{Coverage, 0.29}, {PreMultiplied, 1.0},
	{Coverage, 0.29}, {Coverage, 1.0},
	{Coverage, 0.29}, {NoneBlend, 1.0},

	//7 ~ 10
	{PreMultiplied, 0.29}, {PreMultiplied, 0.65},
	{Coverage, 0.29}, {PreMultiplied, 0.65},
	{PreMultiplied, 0.29}, {Coverage, 0.65},
	{Coverage, 0.29}, {Coverage, 0.65},
};


void oneLayerBlend(struct Color src, struct ComposeConfig srcConfig, struct Color& dst) {
	float gA = srcConfig.gA;
	float R, G , B, A;

	if (srcConfig.blend == PreMultiplied) {
		#if 0
		src.R = src.R * gA;
		src.G = src.G * gA;
		src.B = src.B * gA;
		src.Alpha = src.Alpha * gA;

		R = src.R + dst.R * ((255 - src.Alpha)/255);
		G = src.G + dst.G * ((255 - src.Alpha)/255);
		B = src.B + dst.B * ((255 - src.Alpha)/255);
		A = src.Alpha + dst.Alpha * ((255 - src.Alpha)/255);
		#else
		R = src.R * gA + dst.R * ((255.0 - src.Alpha * gA)/255.0);
		R = src.R * gA + dst.R * ((255.0  - src.Alpha * gA)/255.0);
		G = src.G * gA + dst.G * ((255.0  - src.Alpha * gA)/255.0);
		B = src.B * gA + dst.B * ((255.0 - src.Alpha * gA)/255.0);
		A = src.Alpha * gA + dst.Alpha * ((255.0 - src.Alpha * gA)/255.0);
		#endif
	} else if (srcConfig.blend == Coverage) {
		#if 0 
		src.Alpha = src.Alpha * gA;
		
		R = src.R * src.Alpha / 255 + dst.R * ((255 - src.Alpha)/255);
		G = src.G * src.Alpha / 255 + dst.G * ((255 - src.Alpha)/255);
		B = src.B * src.Alpha / 255 + dst.B * ((255 - src.Alpha)/255);
		A = src.Alpha * src.Alpha / 255 + dst.Alpha * ((255 - src.Alpha)/255);
		#else
		R = src.R * src.Alpha * gA / 255.0 + dst.R * ((255 - src.Alpha * gA)/255);
		G = src.G * src.Alpha * gA / 255.0 + dst.G * ((255 - src.Alpha * gA)/255);
		B = src.B * src.Alpha * gA / 255.0 + dst.B * ((255 - src.Alpha * gA)/255);
		A = src.Alpha * gA * src.Alpha * gA / 255.0 + dst.Alpha * ((255 - src.Alpha * gA)/255);
		#endif
	} else if (srcConfig.blend == NoneBlend) {
		R = src.R;
		G = src.G;
		B = src.B;
		A = 255.0;
	}
	
	dst.R = R;
	dst.G = G;
	dst.B = B;
	dst.Alpha = A;
}

void twoLayerBlend(struct Color& srcTop, struct ComposeConfig & srcTopCfg,
					struct Color& srcBottom, struct ComposeConfig & srcBottomCfg,
					struct Color& dst) {
	if (formulaCaluate == false) {
		oneLayerBlend(srcBottom, srcBottomCfg, dst);
		oneLayerBlend(srcTop, srcTopCfg, dst);
	} 
}

const char* getNameOfBlend(BlendMode mode) {
	switch(mode) {
		case PreMultiplied:
			return "PreMultiplied";
		case Coverage:
			return "Coverage";
		case NoneBlend:
			return "NoneBlend";
		default:
			return "ERROR";
	}
}


int main(int argc, char *argv[]) {
	if (argc <= 1) {
		formulaCaluate = false;
	} else {
		if (*argv[1] == 'f') {
			formulaCaluate = true;
			printf("Caluate by formula\n");
		}
	}
	
	struct Color srcTop = {0x77, 0xcc, 0x55, 0x36};
	struct Color srcBottom = {0x30, 0x5F, 0xDC, 0x99};
	printf("SrcTop:(%x%x%x%x)\n",
			(int)srcTop.R, (int)srcTop.G, (int)srcTop.B, (int)srcTop.Alpha);
	printf("SrcBottom:(%x%x%x%x)\n",
			(int)srcBottom.R, (int)srcBottom.G, (int)srcBottom.B, (int)srcBottom.Alpha);
	
	int cfgIdx = 0;
	for (cfgIdx = 0; cfgIdx < (sizeof(testcfgs)/sizeof(struct ComposeConfig)); ) {
		struct Color dst = {0, 0, 0, 0};
		twoLayerBlend(srcTop, testcfgs[cfgIdx], srcBottom, testcfgs[cfgIdx+1], dst);
		printf("Testcase %d\n", cfgIdx / 2 + 1);
		printf("(%s, %f)+(%s, %f)=(0x%x%x%x%x)\n", 
					getNameOfBlend(testcfgs[cfgIdx].blend), testcfgs[cfgIdx].gA, getNameOfBlend(testcfgs[cfgIdx+1].blend), testcfgs[cfgIdx+1].gA,
					(int)dst.R, (int)dst.G, (int)dst.B, (int)dst.Alpha);
		printf("***********************\n");
		cfgIdx += 2;
	}

	return 0;
}



