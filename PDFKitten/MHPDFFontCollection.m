#import "MHPDFFontCollection.h"


@implementation MHPDFFontCollection

/* Applier function for font dictionaries */
void didScanFont(const char *key, CGPDFObjectRef object, void *collection)
{
	if (!CGPDFObjectGetType(object) == kCGPDFObjectTypeDictionary) return;
	CGPDFDictionaryRef dict;
	if (!CGPDFObjectGetValue(object, kCGPDFObjectTypeDictionary, &dict)) return;
	MHPDFFont *font = [MHPDFFont fontWithDictionary:dict];
	if (!font) return;
	NSString *name = [NSString stringWithUTF8String:key];
	[(NSMutableDictionary *)collection setObject:font forKey:name];
	MHLog(@" %s: %@", key, font);
}

/* Initialize with a font collection dictionary */
- (id)initWithFontDictionary:(CGPDFDictionaryRef)dict
{
	if ((self = [super init]))
	{
		MHLog(@"Font Collection (%d)", CGPDFDictionaryGetCount(dict));
		fonts = [[NSMutableDictionary alloc] init];
		// Enumerate the Font resource dictionary
		CGPDFDictionaryApplyFunction(dict, didScanFont, fonts);

		NSMutableArray *namesArray = [NSMutableArray array];
		for (NSString *name in [fonts allKeys])
		{
			[namesArray addObject:name];
		}

		names = [[namesArray sortedArrayUsingSelector:@selector(compare:)] retain];
	}
	return self;
}

/* Returns a copy of the font dictionary */
- (NSDictionary *)fontsByName
{
	return [NSDictionary dictionaryWithDictionary:fonts];
}

/* Return the specified font */
- (MHPDFFont *)fontNamed:(NSString *)fontName
{
	return [fonts objectForKey:fontName];
}

#pragma mark - Memory Management

- (void)dealloc
{
	[names release];
	[fonts release];
	[super dealloc];
}

@synthesize names;
@end
