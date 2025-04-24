# isj_proj7_xpokorr00.py

from collections import UserDict
from bisect import bisect_right

class TimeSeriesDB(UserDict):
    """
    A class with UserDict data type and and working with timestamp
    """

    def __init__(self):
        """Default empty initialization"""
        super().__init__()

    def __setitem__(self, key, value):
        """If the key is default, it adds (timestamp, value)"""
        timestamp, val = value
        if key not in self.data:
            self.data[key] = []
        # Ascending order
        if self.data[key] and timestamp < self.data[key][-1][0]:
            raise ValueError("Must be in ascending order")
        self.data[key].append((timestamp, val))

    def __getitem__(self, key):
        """
        Gets the item from DB

        - Key == string => returns the last known value
        - (key, timestamp) == pair => returns the value with the biggest timestamp
        """
        if isinstance(key, tuple) and len(key) == 2:
            actual_key, timestamp = key
            if actual_key not in self.data:
                raise KeyError(f"No data for key: {actual_key}")

            ts_arr = self.data[actual_key]
            timestamps = [ts for ts, _ in ts_arr]

            # This method is to find the first (timestamp < searched item) 
            index = bisect_right(timestamps, timestamp)
            if index == 0:
                raise KeyError(f"No timestamp for: {actual_key} at or before {timestamp}")
            return ts_arr[index - 1][1]

        elif isinstance(key, str):
            if key not in self.data or not self.data[key]:
                raise KeyError(f"No data for: {key}")
            return self.data[key][-1][1]
        else:
            raise TypeError("Wrong data type")


def test():
    time_db = TimeSeriesDB()

    time_db['vibr'] = (1, 'low')
    time_db['vibr'] = (5, 'mid')
    time_db['vibr'] = (8, 'low')
    time_db['vibr'] = (12, 'high')

    time_db['temp'] = (2, 37.6)
    time_db['temp'] = (4, 37.2)
    time_db['temp'] = (17, 37.7)

    assert time_db[('vibr', 1)] == 'low'
    assert time_db[('vibr', 4)] == 'low'
    assert time_db[('vibr', 7)] == 'mid'
    assert time_db['temp'] == 37.7


if __name__ == '__main__':
    test()