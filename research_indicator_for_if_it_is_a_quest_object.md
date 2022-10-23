# Research: Indicator for if it is a quest object

## GMR.ObjectDynamicFlags

-65020 = -0b1111110111111100

Test subject: Khaliiq
When it glew.

```
/dump GMR.ObjectDynamicFlags('target')
```

Result:

```
0
```

```
/dump GMR.ObjectFlags('target')
```

Result:

```
33536
```

```
/dump GMR.ObjectFlags2('target')
```

Result:

```
2048
```

When glow was absent.

```
/dump GMR.ObjectDynamicFlags('target')
```

Result:

```
0
```

```
/dump GMR.ObjectFlags('target')
```

Result:

```
33536
```

```
/dump GMR.ObjectFlags2('target')
```

Result:

```
2048
```
