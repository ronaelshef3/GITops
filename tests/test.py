import unittest


class MyTestCase(unittest.TestCase):
    def test_something(self):
        self.assertEqual(True, True)  # add assertion here

    def test_something1(self):
        self.assertEqual(1, 1)  # add assertion here

    def test_something2(self):
        self.assertEqual(True, True)  # add assertion here
    def test_something3(self):
        self.assertEqual(True, True)  # add assertion here
if __name__ == '__main__':
    unittest.main()
