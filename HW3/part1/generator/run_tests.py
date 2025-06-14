import subprocess as sb
import difflib
import os

RED = '\033[91m'
GREEN = '\033[92m'
RESET = '\033[0m'

def run_test(t_name: int, in_name: str, expected_name: str):
    result = sb.run(["./test.exe", f'./tests_in/{in_name}'], stdout=sb.PIPE)
    output = result.stdout.decode("ascii")

    os.makedirs('./tests_out', exist_ok=True)
    output_path = f'./tests_out/{expected_name}'
    expected_path = f'./tests_expected/{expected_name}'
    with open(output_path, 'w', encoding='ascii') as f:
        f.write(output)

    with open(output_path, encoding='ascii') as file_1:
        file_1_text = file_1.readlines()

    with open(expected_path, encoding='ascii') as file_2:
        file_2_text = file_2.readlines()

    diff = difflib.SequenceMatcher(None, file_1_text, file_2_text)

    if diff.ratio() == 1.0:
        print(f'test {t_name:03}: \t {GREEN}PASSED{RESET}')
    else:
        print(f'test {t_name:03}: \t {RED}FAILED{RESET}')


def run_all_tests():
    fnames = os.listdir('./tests_in')
    for name in fnames:
        tname, _ = name.split('.')
        _, t_num = tname.split('_')
        run_test(int(t_num), name, name)

if __name__ == '__main__':
    run_all_tests()