%module Hotrod

%include "arrays_java.i"
%include "typemaps.i"
%include "various.i"
%include "std_string.i"
%include "std_map.i"
%include "std_set.i"
%include "std_vector.i"
%include "stdint.i"

//#define SWIG_SHARED_PTR_NAMESPACE std
//#define SWIG_SHARED_PTR_SUBNAMESPACE tr1
//%include "std_shared_ptr.i"


%include "std_pair.i"

//#define HR_SHARED_PTR std::tr1::shared_ptr

%{
#include <infinispan/hotrod/defs.h>
#include <infinispan/hotrod/ConnectionPoolConfiguration.h>
#include <infinispan/hotrod/exceptions.h>
#include <infinispan/hotrod/ServerConfiguration.h>
#include <infinispan/hotrod/SslConfiguration.h>
#include <infinispan/hotrod/Configuration.h>
#include <infinispan/hotrod/ServerConfigurationBuilder.h>
#include <infinispan/hotrod/ConfigurationBuilder.h>
#include <infinispan/hotrod/MetadataValue.h>
#include <infinispan/hotrod/VersionedValue.h>
#include <infinispan/hotrod/Flag.h>
#include <infinispan/hotrod/TimeUnit.h>
#include <infinispan/hotrod/RemoteCacheManager.h>
#include <infinispan/hotrod/RemoteCache.h>
#include <infinispan/hotrod/ScopedBuffer.h>
#include <infinispan/hotrod/Marshaller.h>

#include <iostream>
%}

%template(MapType) std::map<std::string, std::string>;

%include "infinispan/hotrod/defs.h"
%include "infinispan/hotrod/ImportExport.h"
%include "infinispan/hotrod/Builder.h"
%include "infinispan/hotrod/ConnectionPoolConfiguration.h"
%include "infinispan/hotrod/ServerConfiguration.h"
%include "infinispan/hotrod/SslConfiguration.h"
%include "infinispan/hotrod/Configuration.h"

%template(Builder_conf) infinispan::hotrod::Builder<infinispan::hotrod::Configuration>;
%template(Builder_serverconf) infinispan::hotrod::Builder<infinispan::hotrod::ServerConfiguration>;
%template(Builder_poolconf) infinispan::hotrod::Builder<infinispan::hotrod::ConnectionPoolConfiguration>;
%template(Builder_sslconf) infinispan::hotrod::Builder<infinispan::hotrod::SslConfiguration>;

%include "infinispan/hotrod/ConfigurationChildBuilder.h"
%include "infinispan/hotrod/SslConfigurationBuilder.h"
%include "infinispan/hotrod/ServerConfigurationBuilder.h"
%include "infinispan/hotrod/ConnectionPoolConfigurationBuilder.h"
%include "infinispan/hotrod/ConfigurationBuilder.h"
%include "infinispan/hotrod/VersionedValue.h"
%include "infinispan/hotrod/MetadataValue.h"
%include "infinispan/hotrod/Flag.h"
%include "infinispan/hotrod/TimeUnit.h"
%include "infinispan/hotrod/RemoteCacheManager.h"
%include "infinispan/hotrod/RemoteCache.h"
%include "infinispan/hotrod/Marshaller.h"

%include "infinispan/hotrod/exceptions.h"

%exception {
    try {
        $action
    } catch (const infinispan::hotrod::InvalidResponseException& e) {
      jclass clazz = jenv->FindClass("org/infinispan/client/hotrod/exceptions/InvalidResponseException");
      jenv->ThrowNew(clazz, e.what());
      return $null;
    } catch (const infinispan::hotrod::RemoteCacheManagerNotStartedException& e) {
      jclass clazz = jenv->FindClass("org/infinispan/client/hotrod/exceptions/RemoteCacheManagerNotStartedException");
      jenv->ThrowNew(clazz, e.what());
      return $null;
    } catch (const infinispan::hotrod::UnsupportedOperationException& e) {
      jclass clazz = jenv->FindClass("java/lang/UnsupportedOperationException");
      jenv->ThrowNew(clazz, e.what());
      return $null;
    } catch (const infinispan::hotrod::HotRodClientException& e) {
      jclass clazz = jenv->FindClass("org/infinispan/client/hotrod/exceptions/HotRodClientException");
      jenv->ThrowNew(clazz, e.what());
      return $null;
    } catch (const infinispan::hotrod::Exception& e) {
      jclass clazz = jenv->FindClass("java/lang/Exception");
      jenv->ThrowNew(clazz, e.what());
      return $null;
    } catch (const std::runtime_error& e) {
      SWIG_exception(SWIG_RuntimeError, e.what());
      return $null;
    } catch (const std::exception& e) {
      jclass clazz = jenv->FindClass("java/lang/Exception");
      jenv->ThrowNew(clazz, e.what());
      return $null;
    } catch (const std::exception *e) {
      jclass clazz = jenv->FindClass("java/lang/Exception");
      jenv->ThrowNew(clazz, e->what());
      return $null;
    } catch (...) {
      SWIG_exception(SWIG_UnknownError, "C++ unknown exception thrown");
      return $null;
    }
}

// One class to pass bytes between the JVM and the native classes
// For the exclusive use of Relay marshalling

%ignore RelayBytes::setNative;
%ignore RelayBytes::setJvm;
%ignore RelayBytes::getBytes;
%ignore RelayBytes::getJarray;

//%shared_ptr(RelayShrPointer)

%inline %{

class RelayBytes {
  public:
    void setNative(char *b, size_t l) {bytes = b; length = l;}
    void setJvm(char *b, size_t l, jbyteArray a) {bytes = b; length = l; jarray = a; }
    char *getBytes () const {return bytes;}
    size_t getLength () const {return length; }
    jbyteArray getJarray() const { return jarray; }
    bool isNull() const { return !bytes; }
  private:
    char *bytes;
    size_t length;
    jbyteArray jarray;
};

%}

//%template(RelayShrPointer) HR_SHARED_PTR<RelayBytes>;
%template(MetadataPairReturn) std::pair<HR_SHARED_PTR<RelayBytes>, infinispan::hotrod::MetadataValue>;
%template(VersionPairReturn) std::pair<HR_SHARED_PTR<RelayBytes>, infinispan::hotrod::VersionedValue>;
%template(MapReturn) std::map<HR_SHARED_PTR<RelayBytes>, HR_SHARED_PTR<RelayBytes> >;
%template(SetReturn) std::set<HR_SHARED_PTR<RelayBytes> >;
%template(VectorReturn) std::vector<HR_SHARED_PTR<RelayBytes> >;
%template(StringVectorReturn) std::vector<std::string>;

%inline %{
 bool isNull(HR_SHARED_PTR<RelayBytes> ptr) {
     return !ptr;
 }

 RelayBytes dereference(HR_SHARED_PTR<RelayBytes> ptr) {
     return *ptr;
 }
 
 std::vector<HR_SHARED_PTR<RelayBytes> > keySet(std::map<HR_SHARED_PTR<RelayBytes>, HR_SHARED_PTR<RelayBytes> > map) {
     std::vector<HR_SHARED_PTR<RelayBytes> > result;
     for (std::map<HR_SHARED_PTR<RelayBytes>, HR_SHARED_PTR<RelayBytes> >::iterator it = map.begin(); it != map.end(); ++it)
         result.push_back(it->first);
     return result;
 }
 
 std::vector<HR_SHARED_PTR<RelayBytes> > keys(std::set<HR_SHARED_PTR<RelayBytes> > set) {
     std::vector<HR_SHARED_PTR<RelayBytes> > result;
     for (std::set<HR_SHARED_PTR<RelayBytes> >::iterator it = set.begin(); it != set.end(); ++it)
         result.push_back(*it);
     return result;
 }
 
 std::vector<std::string > keySet(std::map<std::string, std::string > map) {
     std::vector<std::string > result;
     for (std::map<std::string, std::string >::iterator it = map.begin(); it != map.end(); ++it)
         result.push_back(it->first);
     return result;
 }
%}

// our mechanism for RemoteCache<byte[], byte[]> from the java side
%template(RemoteCache_jb_jb) infinispan::hotrod::RemoteCache<RelayBytes, RelayBytes>;

# create a do-nothing marshaller works with the pre-marshalled data

%{
using infinispan::hotrod::ScopedBuffer;

class RelayMarshallerHelper {
  public:
    static void noRelease(ScopedBuffer*) { /* nothing allocated, nothing to release */ }
};

class RelayMarshaller: public infinispan::hotrod::Marshaller<RelayBytes> {
  public:
    void marshall(const RelayBytes& jb, ScopedBuffer& b) {
	if (jb.getLength() == 0) {
	    return;
	}
        b.set(jb.getBytes(), jb.getLength(), &RelayMarshallerHelper::noRelease);
    }
    RelayBytes* unmarshall(const ScopedBuffer& sbuf) {
	RelayBytes* rbytes = new RelayBytes();
	size_t size = sbuf.getLength();
	char *bytes = new char[size];
	memcpy(bytes, sbuf.getBytes(), size);
	rbytes->setNative(bytes, size);
	return rbytes;
    }
};

%}

infinispan::hotrod::RemoteCache<RelayBytes, RelayBytes>* getJniRelayCache(infinispan::hotrod::RemoteCacheManager& mgr, bool forceReturnValue);
infinispan::hotrod::RemoteCache<RelayBytes, RelayBytes>* getJniRelayNamedCache(infinispan::hotrod::RemoteCacheManager& mgr, std::string name, bool forceReturnValue);

%{
using infinispan::hotrod::Marshaller;
using infinispan::hotrod::RemoteCache;
using infinispan::hotrod::RemoteCacheManager;

// Allow a heap allocated instance of RemoteCache<RelayBytes,RelayBytes> 
// for JNI purposes


class RelayCacheBlob {
  public:
     RelayCacheBlob(RemoteCacheManager &m, bool forceReturnValue) : 
       cache(m.getCache<RelayBytes, RelayBytes>(new RelayMarshaller(), &Marshaller<RelayBytes>::destroy,
                                                new RelayMarshaller(), &Marshaller<RelayBytes>::destroy, forceReturnValue)) {}

     RelayCacheBlob(RemoteCacheManager &m, std::string &name, bool forceReturnValue) : 
       cache(m.getCache<RelayBytes, RelayBytes>(new RelayMarshaller(), &Marshaller<RelayBytes>::destroy,
                                                new RelayMarshaller(), &Marshaller<RelayBytes>::destroy, name.c_str(), forceReturnValue)) {}

     RemoteCache<RelayBytes, RelayBytes> *getCache() {
       return &cache;
     }

  private:
     RemoteCache<RelayBytes, RelayBytes> cache;
};


RemoteCache<RelayBytes, RelayBytes>* getJniRelayCache(RemoteCacheManager& mgr, bool forceReturnValue) {
    RelayCacheBlob *p = new RelayCacheBlob(mgr, forceReturnValue); // leak (test only): TODO: blob cleanup
    return p->getCache();
}

RemoteCache<RelayBytes, RelayBytes>* getJniRelayNamedCache(RemoteCacheManager& mgr, std::string name, bool forceReturnValue) {
    RelayCacheBlob *p = new RelayCacheBlob(mgr, name, forceReturnValue); // leak (test only): TODO: blob cleanup
    return p->getCache();
}

%}



%{

extern "C" {
SWIGEXPORT jlong JNICALL Java_org_infinispan_client_hotrod_jni_HotrodJNI2_new_1JniTest(JNIEnv *jenv, jclass jcls) {
  jlong jresult = 0 ;
  
  (void)jenv;
  (void)jcls;
  jresult = 77;
  return jresult;
}

// The following hand coded JNICALL functions are modified swig stubs
// TODO: replace with proper typemaps.  Bonus points for saving a memcpy.
// ZZZ more doc

// setJvmBytes() get a pointer to the jbyteArray without copying

SWIGEXPORT void JNICALL Java_org_infinispan_client_hotrod_jni_HotrodJNI2_setJvmBytes(JNIEnv *jenv, jclass jcls, jlong jarg1, jbyteArray jarg2) {
    (void) jcls;
    RelayBytes *arg1 = (RelayBytes *) jarg1;
    arg1->setJvm((char *) jenv->GetByteArrayElements(jarg2, 0),
		 (size_t) jenv->GetArrayLength(jarg2), jarg2);
}


SWIGEXPORT void JNICALL Java_org_infinispan_client_hotrod_jni_HotrodJNI2_releaseJvmBytes(JNIEnv *jenv, jclass jcls, jlong jarg1, jbyteArray jarg2) {
    (void) jcls;
    RelayBytes *arg1 = (RelayBytes *) jarg1;
    if (arg1->getBytes())
	jenv->ReleaseByteArrayElements(arg1->getJarray(), (jbyte *) arg1->getBytes(), 0);
}


SWIGEXPORT void JNICALL Java_org_infinispan_client_hotrod_jni_HotrodJNI2_readNative(JNIEnv *jenv, jclass jcls, jlong jarg1, jbyteArray jarg2) {
    (void) jcls;
    RelayBytes *arg1 = (RelayBytes *) jarg1;
    jbyte *target = jenv->GetByteArrayElements(jarg2, 0);
    char *source = arg1->getBytes();
    memcpy(target, source, arg1->getLength());
    jenv->ReleaseByteArrayElements(jarg2, target, 0);
    arg1->setNative(0,0);
    delete[] source;
}

}

%}
