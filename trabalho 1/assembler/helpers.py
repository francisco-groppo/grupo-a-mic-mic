#attempts to convert to binary
to_binary = lambda x: x >= 0 and str(bin(x))[2:] or "-" + str(bin(x))[3:]

#attempts to identify types of commands
is_l_command = lambda i : i.find(':') != -1 # labels ends with ':' 
is_a_command = lambda i : i.find(' ') == 0 or i.find('\t') == 0 # assembly commands must be indented (further removed)
is_d_command = lambda i : i.find('.') == 0 # data variables starts with '.'

#attempts to parse an integer
def try_parse_int(s, base=10, val=None):
  try:
    return int(s, base)
  except ValueError:
    return val
  
def set_abit(comp):
  if comp.find('M') != -1:
    return "1"
  else:	
    return "0"

#pads binary translation with addition 0's
def to_b(a, size=8):
  num = to_binary(a)
  length = len(num)
  diff = size - length
  rest = [ "0" for i in range(diff) ]
  rest = "".join(rest)
  return rest + num

def filter_line(a, op="#"):
  idx = a.find(op)
  if idx == -1:
    return a
  elif idx == 0:
    return ''
  else:
    if op == "#":
      a = a[:(idx-1)]
    else:
      a = a[:idx]
  return a
