import string
import random
import os

import configurations as conf

def _distribute_lengths(sum_length: int, n_slots: int, max_len: int) -> list:
    """
    Distribute `sum_length` non-negative units across `n_slots` slots, each slot ≤ max_len.
    Returns a list of length `n_slots`. Raises ValueError if impossible.
    Uses an even-ish distribution: base = sum_length // n_slots, then distribute the remainder.
    """
    if n_slots < 0:
        raise ValueError(f"Number of slots cannot be negative: got {n_slots}")
    if n_slots == 0:
        if sum_length != 0:
            raise ValueError(f"No slots to distribute into, but sum_length={sum_length} > 0")
        return []
    if sum_length < 0:
        raise ValueError(f"sum_length must be non-negative, got {sum_length}")
    # Check overall capacity
    if sum_length > max_len * n_slots:
        raise ValueError(f"Cannot distribute sum_length={sum_length} into {n_slots} slots with max_len={max_len} each")
    base = sum_length // n_slots
    rem = sum_length % n_slots
    if base > max_len:
        raise ValueError(f"Base allocation {base} exceeds max_len={max_len}")
    lengths = [base] * n_slots
    # Distribute remainder: add +1 to as many slots as rem, but not exceeding max_len
    i = 0
    while rem > 0 and i < n_slots:
        if lengths[i] < max_len:
            lengths[i] += 1
            rem -= 1
        i += 1
        if i == n_slots and rem > 0:
            # wrap around; but if no slot < max_len, impossible
            if all(l >= max_len for l in lengths):
                break  # will raise below
            i = 0
    if rem != 0:
        raise ValueError("Unable to distribute remainder without exceeding max_len")
    return lengths


def create_message(
    total_length: int,
    num_newlines: int,
    special_char: str,
    longest_line_length: int,
    max_special_in_line: int,
    end_with_newline: bool = False,
    random_seed: int = None
) -> str:
    """
    Create and return a message string of total length `total_length` (including newline chars),
    containing exactly `num_newlines` newline characters, such that:
      - There are `num_newlines + 1` lines (some possibly empty).
      - The length of the longest line (excluding newline) is exactly `longest_line_length`.
      - The maximum number of occurrences of `special_char` in any single line is exactly `max_special_in_line`.
      - Other lines may also contain between 0 and `max_special_in_line` occurrences of `special_char`.
      - All lines have length ≤ `longest_line_length`, and occurrences ≤ `max_special_in_line`.
      - If end_with_newline=True, the message ends with a newline character.
    Optionally, pass `random_seed` to have reproducible random choices.
    Raises ValueError if requirements cannot be met.
    """
    # Seed random if requested
    if random_seed is not None:
        random.seed(random_seed)

    # Basic validations
    if not isinstance(total_length, int) or total_length < 0:
        raise ValueError(f"total_length must be a non-negative integer, got {total_length}")
    if not isinstance(num_newlines, int) or num_newlines < 0:
        raise ValueError(f"num_newlines must be a non-negative integer, got {num_newlines}")
    if not isinstance(special_char, str) or len(special_char) != 1:
        raise ValueError(f"special_char must be a single-character string, got {special_char!r}")
    if not isinstance(longest_line_length, int) or longest_line_length < 0:
        raise ValueError(f"longest_line_length must be a non-negative integer, got {longest_line_length}")
    if not isinstance(max_special_in_line, int) or max_special_in_line < 0:
        raise ValueError(f"max_special_in_line must be a non-negative integer, got {max_special_in_line}")
    if not isinstance(end_with_newline, bool):
        raise ValueError(f"end_with_newline must be a boolean, got {end_with_newline}")

    # If end_with_newline=True, we require at least one newline to end with
    if end_with_newline and num_newlines < 1:
        raise ValueError("end_with_newline=True but num_newlines<1: cannot end with newline if no newlines are allowed")

    # total_length must at least fit num_newlines
    if total_length < num_newlines:
        raise ValueError(f"total_length={total_length} is smaller than num_newlines={num_newlines}")

    sum_line_lengths = total_length - num_newlines
    n_lines = num_newlines + 1

    # Validate that at least one line can reach longest_line_length
    if longest_line_length > sum_line_lengths:
        raise ValueError(f"longest_line_length={longest_line_length} exceeds total available non-newline chars {sum_line_lengths}")

    # Validate special_char appearances constraint
    if max_special_in_line > longest_line_length:
        raise ValueError(f"max_special_in_line={max_special_in_line} exceeds longest_line_length={longest_line_length}: cannot place so many special chars in a line of length {longest_line_length}")

    # Prepare lengths array
    if end_with_newline:
        # Last line must be empty
        if n_lines - 1 <= 0:
            raise ValueError("Internal error: unexpected n_lines for end_with_newline")
        # Distribute sum_line_lengths over first n_lines-1 lines
        if sum_line_lengths < longest_line_length:
            raise ValueError(f"With end_with_newline=True, sum of lengths to distribute ({sum_line_lengths}) must be at least longest_line_length ({longest_line_length})")
        if sum_line_lengths > longest_line_length * (n_lines - 1):
            raise ValueError(f"With end_with_newline=True, sum of lengths ({sum_line_lengths}) exceeds capacity {(n_lines-1)} * {longest_line_length}")

        lengths = [0] * n_lines
        lengths[-1] = 0  # last line empty
        # We first select one index among [0..n_lines-2] to be at least longest_line_length.
        # But in distribution, we want exactly one line to be forced to longest (so we ensure the max), 
        # while other lines ≤ longest_line_length. Which line? We'll pick randomly among available slots.
        # However, we must ensure sum_line_lengths >= longest_line_length, which is checked above.
        # First pick an index for the “forced” longest line:
        idx_longest = random.randrange(0, n_lines - 1)  # among 0..n_lines-2
        lengths[idx_longest] = longest_line_length
        remain = sum_line_lengths - longest_line_length
        # Now distribute remain over the other (n_lines-2) slots (if any)
        n_slots = (n_lines - 1) - 1  # excluding idx_longest and last empty line
        if n_slots == 0:
            if remain != 0:
                raise ValueError("No other lines to distribute remaining characters, but remain != 0")
            # else exactly one non-empty line, done.
        else:
            dist = _distribute_lengths(remain, n_slots, longest_line_length)
            # Fill into the other indices 0..n_lines-2 except idx_longest
            fill_idxs = [i for i in range(n_lines - 1) if i != idx_longest]
            # To add randomness in which line gets which share, shuffle fill_idxs before assignment
            random.shuffle(fill_idxs)
            for i, li in enumerate(dist):
                lengths[ fill_idxs[i] ] = li
    else:
        # No requirement to force a trailing newline.
        # sum_line_lengths must fit into n_lines * longest_line_length
        if sum_line_lengths > longest_line_length * n_lines:
            raise ValueError(f"sum of lengths ({sum_line_lengths}) exceeds capacity {n_lines} * {longest_line_length}")

        lengths = [0] * n_lines
        # Pick one index to force to longest_line_length, among 0..n_lines-1; but later, distribution may cause other lines to also reach longest if sum allows.
        idx_longest = random.randrange(0, n_lines)
        lengths[idx_longest] = longest_line_length
        remain = sum_line_lengths - longest_line_length
        n_slots = n_lines - 1
        if n_slots == 0:
            if remain != 0:
                raise ValueError("No other lines to distribute remaining characters, but remain != 0")
        else:
            dist = _distribute_lengths(remain, n_slots, longest_line_length)
            fill_idxs = [i for i in range(n_lines) if i != idx_longest]
            random.shuffle(fill_idxs)
            for i, li in enumerate(dist):
                lengths[ fill_idxs[i] ] = li

    # At this point, `lengths` is a list of length n_lines, sum(lengths) = sum_line_lengths, and max(lengths) == longest_line_length.

    # Decide filler_char (not equal to special_char), from ASCII letters if possible
    for c in string.ascii_letters:
        if c != special_char:
            filler_char = c
            break
    else:
        # fallback
        filler_char = '?' if special_char != '?' else '!'

    # Now decide special_char counts per line.
    # First, collect indices of lines where length >= max_special_in_line
    eligible_idxs = [i for i, L in enumerate(lengths) if L >= max_special_in_line]
    if not eligible_idxs:
        # This shouldn't happen because we forced one line length == longest_line_length >= max_special_in_line
        raise RuntimeError("Internal error: no line is long enough for max_special_in_line")
    # Choose one index at random among eligible to have exactly max_special_in_line
    idx_with_max = random.choice(eligible_idxs)
    special_counts = [0] * n_lines
    special_counts[idx_with_max] = max_special_in_line

    # For other lines, allow random occurrences between 0 and min(line_length, max_special_in_line)
    # (But we already set one line; skip it.)
    for i, L in enumerate(lengths):
        if i == idx_with_max:
            continue
        # possible max for this line is min(L, max_special_in_line)
        max_here = min(L, max_special_in_line)
        if max_here <= 0:
            special_counts[i] = 0
        else:
            # randomly choose between 0 and max_here
            special_counts[i] = random.randint(0, max_here)

    # Build each line string by inserting special_char and filler_char
    lines = []
    for i, L in enumerate(lengths):
        if L == 0:
            lines.append("")
            continue
        cnt_special = special_counts[i]
        cnt_filler = L - cnt_special
        # Compose
        line_chars = [special_char] * cnt_special + [filler_char] * cnt_filler
        # Shuffle so specials are not all clumped
        random.shuffle(line_chars)
        line = ''.join(line_chars)
        lines.append(line)

    # Join lines with '\n'
    if end_with_newline:
        # Last line is empty, so lines[-1] == ""
        # Join lines[0..n_lines-2], then add trailing '\n'
        body = "\n".join(lines[:-1])  # if n_lines-1 >= 1; if exactly 1, it's just lines[0]
        message = body + "\n"
    else:
        message = "\n".join(lines)

    # Final sanity checks
    if len(message) != total_length:
        raise RuntimeError(f"Internal error: generated message length {len(message)} != expected total_length {total_length}")
    if message.count("\n") != num_newlines:
        raise RuntimeError(f"Internal error: generated message has {message.count(chr(10))} newlines, expected {num_newlines}")
    actual_lines = message.split("\n")
    actual_max_len = max(len(ln) for ln in actual_lines)
    if actual_max_len != longest_line_length:
        raise RuntimeError(f"Internal error: actual longest line {actual_max_len} != required {longest_line_length}")
    actual_counts = [ln.count(special_char) for ln in actual_lines]
    if max(actual_counts) != max_special_in_line:
        raise RuntimeError(f"Internal error: actual max special_char count {max(actual_counts)} != required {max_special_in_line}")
    if any(cnt > max_special_in_line for cnt in actual_counts):
        raise RuntimeError("Internal error: some line has more special chars than allowed")

    return message


def generate_random_valid_config(seed=None):
    if seed is not None:
        random.seed(seed)

    def generate():
        end_with_newline = random.choice([True, False])
        total_length = random.randint(conf.MIN_LINE_LEN, conf.MAX_LINE_LEN * conf.MAX_NEW_LINES)
        num_newlines = random.randint(max(1 if end_with_newline else 0, conf.MIN_NEW_LINES), max(conf.MAX_NEW_LINES, min(total_length, conf.MAX_NEW_LINES, total_length // conf.MAX_NEW_LINES)))

        # Available characters for content, excluding newlines
        available_chars = max(1, total_length - (num_newlines - 1))

        # Constraint from create_message: longest_line_length < available_chars
        max_possible_line_length = min(available_chars, conf.MAX_LINE_LEN-1)

        # Ensure min is not greater than max
        min_required_line_length = max(conf.MIN_LINE_LEN, 0 if num_newlines == 0 else ((available_chars + num_newlines - 1) // num_newlines) - 1)
        return {
            'total_length': total_length,
            'num_newlines': num_newlines, 
            'max_possible_line_length': max_possible_line_length,
            'min_required_line_length': min_required_line_length,
            'end_with_newline': end_with_newline
        }
    
    configs = generate()
    while configs['min_required_line_length'] > configs['max_possible_line_length']:
        configs = generate()
    
    if configs['min_required_line_length'] > configs['max_possible_line_length']:
        raise ValueError(f"<min line length> = {configs['min_required_line_length']} \t > \t {configs['max_possible_line_length']} = <max possible line length>")
        # fallback: adjust num_newlines to make it valid
        num_newlines = max(1, total_length // 10)
        available_chars = total_length - (num_newlines - 1)
        max_possible_line_length = min(total_length, available_chars - 1)
        min_required_line_length = max(0, (available_chars + num_newlines - 1) // num_newlines)

    longest_line_length = random.randint(configs['min_required_line_length'], configs['max_possible_line_length'])
    max_special_in_line = random.randint(0, longest_line_length)
    special_char = conf.SPECIAL_CHAR
    

    return {
        "total_length": configs['total_length'],
        "num_newlines": configs['num_newlines'],
        "special_char": special_char,
        "longest_line_length": longest_line_length,
        "max_special_in_line": max_special_in_line,
        "end_with_newline": configs['end_with_newline']
    }


def add_others():
    tests = []
    base_index = conf.NUM_OF_TESTS
    
    if conf.ADD_BASE:
        base_index += 1
        t_name = f'message_{base_index}.txt'
        msg = "I love ATAM\n."
        expected = "There are 2 lines. The longest line is of length 11 and the most repeats of the special character in a single line is 2.\n"
        tests.append({'t_name': t_name, 'msg': msg, 'expected': expected})

        base_index += 1
        t_name = f'message_{base_index}.txt'
        msg = "I love ATAM\n"
        expected = "There are 2 lines. The longest line is of length 11 and the most repeats of the special character in a single line is 2.\n"
        tests.append({'t_name': t_name, 'msg': msg, 'expected': expected})

        # full line with one \n at the end
        base_index += 1
        length = 128
        spc_in_line = random.randint(0, length-1)
        expected = f"There are 2 lines. The longest line is of length {length-1} and the most repeats of the special character in a single line is {spc_in_line}.\n"
        msg = conf.SPECIAL_CHAR * spc_in_line + (128 - spc_in_line - 1) * 'a' + '\n'
        assert (len(msg) == 128)
        tests.append({'t_name': f'message_{base_index}.txt', 'msg': msg, 'expected': expected})
    if conf.ADD_EMPTY:
        base_index += 1
        t_name = f'message_{base_index}.txt'
        expected = "There are 1 lines. The longest line is of length 0 and the most repeats of the special character in a single line is 0.\n"
        tests.append({'t_name': t_name, 'msg': '', 'expected': expected})
    if conf.ADD_ONE_LINERS:
        for i in range(conf.NUM_OF_ONE_LINERS):
            base_index += 1
            t_name = f'message_{base_index}.txt'
            length = random.randint(1, conf.MAX_LINE_LEN)
            spc_in_line = random.randint(0, length)
            msg = create_message(length, 0, conf.SPECIAL_CHAR, length, spc_in_line, random_seed=i)
            expected = f"There are 1 lines. The longest line is of length {length} and the most repeats of the special character in a single line is {spc_in_line}.\n"
            tests.append({'t_name': t_name, 'msg': msg, 'expected': expected})
        
        # full line
        base_index += 1
        length = 128
        spc_in_line = random.randint(0, length)
        expected = f"There are 1 lines. The longest line is of length {length} and the most repeats of the special character in a single line is {spc_in_line}.\n"
        msg = conf.SPECIAL_CHAR * spc_in_line + (128 - spc_in_line) * 'a'
        assert (len(msg) == 128)
        tests.append({'t_name': f'message_{base_index}.txt', 'msg': msg, 'expected': expected})
    return tests

def generate_message_files_randomized(folder_name, num_files):
    input_dir = f'{folder_name}_in'
    output_dir = f'{folder_name}_expected'
    os.makedirs(input_dir, exist_ok=True)
    os.makedirs(output_dir, exist_ok=True)

    for i in range(num_files):
        while True:
            config = generate_random_valid_config()
            config['random_seed'] = i  # still deterministic for reproducibility
            msg = ''
            # config['random_seed'] = random.randint(10, 1000)
            try:
                msg = create_message(**config)
                break
            except:
                continue

        file_path = os.path.join(input_dir, f"message_{i+1}.txt")
        with open(file_path, "w", encoding='ascii') as f:
            f.write(msg)

        out_file_path = os.path.join(output_dir, f"message_{i+1}.txt")
        with open(out_file_path, "w", encoding='ascii') as f:
            num_lines = len(msg.split('\n'))
            out_msg = f'There are {num_lines} lines. The longest line is of length {config["longest_line_length"]} and the most repeats of the special character in a single line is {config["max_special_in_line"]}.\n'
            f.write(out_msg)

        print(f"Created: {file_path} | Config: {config}")
    
    for test in add_others():
        file_path = os.path.join(input_dir, test['t_name'])
        with open(file_path, "w", encoding='ascii') as f:
            f.write(test['msg'])

        out_file_path = os.path.join(output_dir, test['t_name'])
        with open(out_file_path, "w", encoding='ascii') as f:
            f.write(test['expected'])

        print(f"Created: {file_path} | Config: none compatible with edge case tests")


# Example usage:
if __name__ == "__main__":
    generate_message_files_randomized(
        folder_name="tests",
        num_files=conf.NUM_OF_TESTS + conf.NUM_OF_ONE_LINERS + 1 if conf.ADD_BASE else 0 + 1 if conf.ADD_EMPTY else 0
    )