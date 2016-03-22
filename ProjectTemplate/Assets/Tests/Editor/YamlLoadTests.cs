using UnityEngine;
using UnityEditor;
using NUnit.Framework;

namespace UnitTests
{

    public class YamlLoadTests
    {
        class Sample
        {
            public bool bool_true { get; set; }
            public bool bool_false { get; set; }
            public string string_test { get; set; }
            public string[] array_test { get; set; }
            public StructTest struct_test { get; set; }
        }

        public struct StructTest
        {
            public string member1 { get; set; }
            public string member2 { get; set; }
            public string[] empty_array { get; set; }
        }

        string yamlText = @"
bool_true: true
bool_false: false
string_test: test
array_test:
- one
- two
- three
struct_test:
  member1: member1
  member2: member2
  empty_array: []
";

        Sample sample = null;

        [TestFixtureSetUp]
        public void Setup()
        {
            var reader = new System.IO.StringReader(yamlText);
            var deserializer = new YamlDotNet.Serialization.Deserializer(
                namingConvention: new YamlDotNet.Serialization.NamingConventions.UnderscoredNamingConvention()
            );

            this.sample = deserializer.Deserialize<Sample>(reader);
        }

        [TestFixtureTearDown]
        public void TearDown()
        {
            this.sample = null;
        }

        [Test]
        public void BoolMember()
        {
            Assert.IsTrue(sample.bool_true);
            Assert.IsFalse(sample.bool_false);
        }

        [Test]
        public void StringMember()
        {
            Assert.AreEqual("test", sample.string_test);
        }

        [Test]
        public void ArrayMember()
        {
            Assert.AreEqual(3, sample.array_test.Length);
            Assert.Contains("one", sample.array_test);
            Assert.Contains("two", sample.array_test);
            Assert.Contains("three", sample.array_test);
        }

        [Test]
        public void ObjectMember()
        {
            Assert.IsNotNull(sample.struct_test);
            Assert.AreEqual("member1", sample.struct_test.member1);
            Assert.AreEqual("member2", sample.struct_test.member2);
            Assert.IsNotNull(sample.struct_test.empty_array);
            Assert.IsEmpty(sample.struct_test.empty_array);
        }
    }

} // UnitTests
