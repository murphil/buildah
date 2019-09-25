from subprocess import check_output as co

ctr1 = co(f'buildah from alpine'.split(' ')).decode()[0:-1]

print(ctr1)

def run(cmd):
    return co(['buildah', 'run', ctr1, '--', *cmd.split(' ')])

runx = '''
apk update
apk add zsh
'''.split('\n')

for i in runx:
    if len(i)==0:
        continue
    print(f'------------ {i}')
    run(i)
