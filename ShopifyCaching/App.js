import React, { useState, useEffect } from 'react';
import { StatusBar } from 'expo-status-bar';
import { StyleSheet, Text, View, FlatList, TouchableOpacity } from 'react-native';
import { H } from 'highlight.run';

export default function App() {
  const [items, setItems] = useState([]);
  const [selectedItem, setSelectedItem] = useState(null); // Track selected item

  useEffect(() => {
    // Initialize Highlight.io
    H.init('jdkmj47g', {
      serviceName: "frontend-app",
      tracingOrigins: true,
      networkRecording: {
        enabled: true,
        recordHeadersAndBody: true,
        urlBlocklist: [
          "https://www.googleapis.com/identitytoolkit",
          "https://securetoken.googleapis.com",
        ],
      },
    });
    // Fetch items
      fetch('http://127.0.0.1:3000/items', { mode: 'cors' })
        .then((response) => {
          if (!response.ok) {
            throw new Error(`HTTP error! Status: ${response.status}`);
          }
          return response.json();
        })
        .then((data) => setItems(data))
        .catch((error) => {
          console.error('Fetching error: ', error.message);
        });
  }, []);

  const renderItem = ({ item }) => {
    const isSelected = item === selectedItem;

    return (
      <TouchableOpacity
        onPress={() => setSelectedItem(isSelected ? null : item)}
        style={[
          styles.item,
          { backgroundColor: isSelected ? '#6e3b6e' : '#f9c2ff' },
        ]}
      >
        <Text style={[styles.title, { color: isSelected ? 'white' : 'black' }]}>
          {item.name}
        </Text>
      </TouchableOpacity>
    );
  };

  return (
    <View style={styles.container}>
      <FlatList
        data={items}
        keyExtractor={(item) => item.id.toString()}
        renderItem={renderItem}
      />
      <StatusBar style="auto" />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
    alignItems: 'center',
    justifyContent: 'center',
  },
  item: {
    padding: 10,
    marginVertical: 8,
    marginHorizontal: 16,
  },
  title: {
    fontSize: 18,
  },
});
