#import <LibTorch-Lite/LibTorch-Lite.h>
#import <Foundation/Foundation.h>
#import "IValueWrapper.h"
#import "Tensor.h"

@implementation IValueWrapper {
    at::IValue _iValue;
}

- (nullable instancetype)init {
    self = [super init];
    if (self) {
        _iValue = at::IValue();
    }
    return self;
}

- (nullable instancetype)initWithNativeIValue:(void*)nativeIValue {
    self = [super init];
    if (self) {
        _iValue = *((at::IValue*)nativeIValue);
    }
    return self;
}

- (nullable instancetype)initWithTensor:(Tensor*)tensor {
    self = [super init];
    if (self) { _iValue = at::IValue{*((at::Tensor*)(tensor.getTensor))}; }
    return self;
}

- (nullable instancetype)initWithBoolean:(bool)value {
    self = [super init];
    if (self) { _iValue = at::IValue{value}; }
    return self;
}

- (nullable instancetype)initWithLong:(int64_t)value {
    self = [super init];
    if (self) { _iValue = at::IValue{value}; }
    return self;
}

- (nullable instancetype)initWithDouble:(double)value {
    self = [super init];
    if (self) { _iValue = at::IValue{value}; }
    return self;
}

- (nullable instancetype)initWithString:(NSString*)value {
    self = [super init];
    if (self) { _iValue = at::IValue{(char*)[value UTF8String]}; }
    return self;
}

- (nullable instancetype)initWithBooleanList:(bool*)data length:(size_t)length {
    self = [super init];
    if (self) {
        at::ArrayRef<bool> arr = at::ArrayRef<bool>(data, length);
        _iValue = at::IValue{arr};
    }
    return self;
}

- (nullable instancetype)initWithFloatList:(float*)data length:(size_t)length {
    self = [super init];
    if (self) {
        at::ArrayRef<float> arr = at::ArrayRef<float>(data, length);
        _iValue = at::IValue{arr};
    }
    return self;
}

- (nullable instancetype)initWithLongList:(int64_t*)data length:(size_t)length {
    self = [super init];
    if (self) {
        at::ArrayRef<int64_t> arr = at::ArrayRef<int64_t>(data, length);
        _iValue = at::IValue{arr};
    }
    return self;
}

- (nullable instancetype)initWithDoubleList:(double*)data length:(size_t)length {
    self = [super init];
    if (self) {
        at::ArrayRef<double> arr = at::ArrayRef<double>(data, length);
        _iValue = at::IValue{arr};
    }
    return self;
}

- (nullable instancetype)initWithTuple:(NSArray<IValueWrapper*>*)nativeIValues {
    self = [super init];
    if (self) {
        std::vector<at::IValue> vector;
        for (IValueWrapper* nativeIValue in nativeIValues) {
             vector.push_back(nativeIValue->_iValue);
        }
        _iValue = at::IValue(c10::ivalue::Tuple::create(vector));
    }
    return self;
}

- (nullable instancetype)initWithList:(NSArray<IValueWrapper*>*)nativeIValues {
    self = [super init];
    if (self) {
        c10::TypePtr type = c10::NoneType::get();
        if (nativeIValues.count > 0) {
            type = nativeIValues[0]->_iValue.type();
        }

        c10::impl::GenericList list(type);
        for (IValueWrapper* nativeIValue in nativeIValues) {
            list.push_back(nativeIValue->_iValue);
        }
        _iValue = at::IValue(list);
    }
    return self;
}

- (nullable instancetype)initWithTensors:(NSArray<Tensor*>*) tensors {
    self = [super init];
    if (self) {
        c10::TypePtr type = c10::TensorType::get();
        c10::impl::GenericList list(type);
        for (Tensor* tensor in tensors) {
            list.push_back(*((at::Tensor*) (tensor.getTensor)));
        }
        _iValue = at::IValue(list);
    }
    return self;
}



- (Tensor*)toTensor {
    return [[Tensor alloc] initWithTensor: &_iValue.toTensor()];
}

- (bool)toBool { return _iValue.toBool(); }
- (int64_t)toInt { return _iValue.toInt(); }
- (double)toDouble { return _iValue.toDouble(); }

- (NSArray<IValueWrapper*>*)toTuple {
    c10::intrusive_ptr<c10::ivalue::Tuple> iValueList = _iValue.toTuple();
    NSMutableArray* data = [NSMutableArray array];
    std::vector<at::IValue> elements = iValueList->elements();
    for (int i = 0; i < elements.size(); i++) {
        at::IValue iValue = elements[i];
        IValueWrapper *wrapper = [[IValueWrapper alloc] initWithNativeIValue: &iValue];
        [data addObject: wrapper];
    }
    return data;
}

- (NSArray<IValueWrapper*>*)toList {
    c10::List<at::IValue> iValueList = _iValue.toList();
    NSMutableArray* data = [NSMutableArray array];
    for (int i = 0; i < iValueList.size(); i++) {
        at::IValue iValue = iValueList[i];
        IValueWrapper *wrapper = [[IValueWrapper alloc] initWithNativeIValue: &iValue];
        [data addObject:wrapper];
    }
    return data;
}

- (bool)isNone { return _iValue.isNone(); }
- (bool)isTensor { return _iValue.isTensor(); }
- (bool)isBool { return _iValue.isBool(); }
- (bool)isInt { return _iValue.isInt(); }
- (bool)isDouble { return _iValue.isDouble(); }
- (bool)isString { return _iValue.isString(); }
- (bool)isTuple { return _iValue.isTuple(); }
- (bool)isBoolList { return _iValue.isBoolList(); }
- (bool)isIntList { return _iValue.isIntList(); }
- (bool)isDoubleList { return _iValue.isDoubleList(); }
- (bool)isTensorList { return _iValue.isTensorList(); }
- (bool)isList { return _iValue.isList(); }

- (void*)getIValue {
    return &self->_iValue;
}

@end