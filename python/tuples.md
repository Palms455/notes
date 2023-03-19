### Именованный кортеж `collections.namedtuple`
```python
from collections import namedtuple
subscriber = namedtuple("Suscriber", ["var1", "var2", "var3"])
sub = subscriber(1, 2, 3)
sub.val1, sub.val2, sub.val3

# возвращает новый кортеж. Полезен при дополнении полей
sub = sub._replace(var=value) 
```

