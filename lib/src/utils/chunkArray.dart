List<List<T>> chunkArray<T>(List<T> arr, int size) =>
    arr.length > size ? [arr.sublist(0, size), ...chunkArray(arr.sublist(size), size)] : [arr];
