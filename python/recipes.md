### List filters
```python
from itertools import compress
list(compress([...], [...]))
list(compress([1, 2, 3], [True, False, Flase]))
```

более быстрое чем dict comprehension
```python
dict((key, value) for key, value in dict.items() if ..)
```
