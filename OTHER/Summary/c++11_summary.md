# c++11 summary #
---
## 变长template ##
```
template <typename T>
void _print(T t){
    //do something for t
}
template <typename head,typename... Args>
void _print1(head h,Args... args){
    _print(h);
    _print1(args...);//recurse 
}

template <typename... Args>
void _print2(Args... args){
    (_print(args),...);//括号和,不可缺少
}
```

